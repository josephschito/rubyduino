# frozen_string_literal: true

require "English"
require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

require_relative "spinel"

module Rubyduino
  # Encapsulates the rubyduino executable so its helpers don't pollute the
  # top-level Object namespace. Instantiate with the argv array and call
  # {#run} to compile + flash the sketch.
  class CLI
    DEFAULT_MCU = "atmega328p"
    DEFAULT_F_CPU = "16000000UL"
    DEFAULT_BAUD = "115200"

    PORT_GLOBS = %w[
      /dev/cu.usbmodem*
      /dev/cu.usbserial*
      /dev/ttyACM*
      /dev/ttyUSB*
    ].freeze

    AVRDUDE_GLOBS = [
      "/Applications/Arduino.app/Contents/**/bin/avrdude",
      "/opt/homebrew/**/bin/avrdude",
      "/usr/local/**/bin/avrdude"
    ].freeze

    def self.run(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv.dup
      @mcu = DEFAULT_MCU
      @f_cpu = DEFAULT_F_CPU
      @baud = DEFAULT_BAUD
      @port = nil
      @out = nil
      @source = nil
    end

    def run
      parse_argv
      resolve_paths
      validate_environment
      ensure_parser_built
      compile_and_flash
    end

    private

    def parse_argv
      until @argv.empty?
        arg = @argv.shift
        case arg
        when "-p" then @port = require_arg!
        when "-o" then @out = require_arg!
        when "--mcu" then @mcu = require_arg!
        when "--baud" then @baud = require_arg!
        when "-h", "--help" then usage
        when /\.rb\z/
          usage if @source
          @source = arg
        else
          usage
        end
      end
      usage unless @source
    end

    def require_arg!
      usage if @argv.empty?
      @argv.shift
    end

    def usage
      warn "Usage: rubyduino [options] input.rb"
      warn ""
      warn "Options:"
      warn "  -p PORT      Serial port, e.g. /dev/cu.usbmodem31401"
      warn "  -o NAME      Output base path without extension"
      warn "  --mcu MCU    AVR MCU, default: #{DEFAULT_MCU}"
      warn "  --baud BAUD  Upload baud, default: #{DEFAULT_BAUD}"
      exit 1
    end

    def resolve_paths
      @root_dir = File.expand_path("../..", __dir__)
      @root_dir = File.expand_path("../..", Rubyduino::Spinel::ROOT) unless Dir.exist?(File.join(@root_dir, "vendor/spinel"))

      @spinel_dir = File.join(@root_dir, "vendor/spinel")
      @rubyduino_dir = File.join(@root_dir, "lib/rubyduino")
      @parse_bin = File.join(@spinel_dir, "spinel_parse")
      @codegen_rb = File.join(@rubyduino_dir, "spinel_arduino_codegen.rb")
      @entry_c = File.join(@rubyduino_dir, "arduino_entry.c")
      @arduino_uno_rb = File.join(@rubyduino_dir, "arduino_uno.rb")

      @out ||= @source.end_with?(".rb") ? @source.delete_suffix(".rb") : @source
      @c_file = "#{@out}.c"
      @elf_file = "#{@out}.elf"
      @hex_file = "#{@out}.hex"
      @app_obj = "#{@out}.o"
      @entry_obj = "#{@out}.entry.o"
    end

    def validate_environment
      abort "rubyduino: #{@source}: No such file" unless File.file?(@source)
      abort "rubyduino: missing Spinel checkout at #{@spinel_dir}" unless Dir.exist?(@spinel_dir)
      abort "rubyduino: missing #{@codegen_rb}" unless File.file?(@codegen_rb)
      abort "rubyduino: missing #{@entry_c}" unless File.file?(@entry_c)
      abort "rubyduino: missing #{@arduino_uno_rb}" unless File.file?(@arduino_uno_rb)
      abort "rubyduino: avr-gcc not found" unless command?("avr-gcc")
      abort "rubyduino: avr-objcopy not found" unless command?("avr-objcopy")
    end

    def ensure_parser_built
      return if File.executable?(@parse_bin)

      if command?("make")
        warn "Spinel: building parser in #{@spinel_dir}"
        prism_header = File.join(@spinel_dir, "vendor/prism/include/prism/diagnostic.h")
        run!("make", "-C", @spinel_dir, "deps") unless File.file?(prism_header)
        run!("make", "-C", @spinel_dir, "PRISM_DIR=vendor/prism", "parse")
      end

      abort "rubyduino: missing #{@parse_bin}; run 'make -C #{@spinel_dir} parse'" unless File.executable?(@parse_bin)
    end

    def compile_and_flash
      @port ||= find_port
      abort "rubyduino: no Arduino serial port found; pass -p /dev/..." unless @port

      avrdude = find_avrdude
      abort "rubyduino: avrdude not found" unless avrdude

      ast_tmp = File.join(Dir.tmpdir, "spinel_arduino_ast.#{$PROCESS_ID}.#{rand(1_000_000)}")
      source_tmp = File.join(Dir.tmpdir, "rubyduino_source.#{$PROCESS_ID}.#{rand(1_000_000)}.rb")
      begin
        warn "Spinel: #{@source} -> #{@c_file}"
        File.write(source_tmp, "#{File.read(@arduino_uno_rb)}\n#{File.read(@source)}")
        run!(@parse_bin, source_tmp, ast_tmp)
        run!(RbConfig.ruby, @codegen_rb, ast_tmp, @c_file)

        warn "AVR: #{@c_file} -> #{@hex_file}"
        compile_flags = ["-Os", "-DF_CPU=#{@f_cpu}", "-mmcu=#{@mcu}",
                         "-I#{@rubyduino_dir}", "-I#{File.join(@spinel_dir, "lib")}"]
        run!("avr-gcc", *compile_flags, "-Dmain=sp_arduino_user_main", "-c", @c_file, "-o", @app_obj)
        run!("avr-gcc", *compile_flags, "-c", @entry_c, "-o", @entry_obj)
        run!("avr-gcc", "-Os", "-DF_CPU=#{@f_cpu}", "-mmcu=#{@mcu}", @app_obj, @entry_obj, "-o", @elf_file)
        run!("avr-objcopy", "-O", "ihex", "-R", ".eeprom", @elf_file, @hex_file)
        run!("avr-size", "--mcu=#{@mcu}", "--format=avr", @elf_file) if command?("avr-size")

        warn "Flash: #{@hex_file} -> #{@port}"
        conf = avrdude_conf_for(avrdude)
        conf_args = conf ? ["-C#{conf}"] : []
        run!(avrdude, *conf_args, "-p#{@mcu}", "-carduino", "-P#{@port}", "-b#{@baud}", "-D", "-Uflash:w:#{@hex_file}:i")
      ensure
        FileUtils.rm_f(ast_tmp)
        FileUtils.rm_f(source_tmp)
      end
    end

    def run!(*cmd, chdir: nil, env: {})
      options = {}
      options[:chdir] = chdir if chdir
      ok = system(env, *cmd, **options)
      return if ok

      status = $CHILD_STATUS&.exitstatus
      abort "rubyduino: command failed#{status ? " with exit #{status}" : ""}: #{cmd.join(" ")}"
    end

    def capture!(*cmd)
      out, status = Open3.capture2e(*cmd)
      return out.strip if status.success?

      abort out.empty? ? "rubyduino: command failed: #{cmd.join(" ")}" : out
    end

    def command?(name)
      !executable(name).nil?
    end

    def executable(name)
      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).filter_map do |dir|
        path = File.join(dir, name)
        path if File.file?(path) && File.executable?(path)
      end.first
    end

    def runnable_executable?(path)
      _output, status = Open3.capture2e(path, "-?")
      status.success?
    rescue SystemCallError
      false
    end

    def find_port
      PORT_GLOBS.lazy.flat_map { |pattern| Dir.glob(pattern) }.first
    end

    def find_avrdude
      candidates = ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).filter_map do |dir|
        path = File.join(dir, "avrdude")
        path if File.file?(path) && File.executable?(path)
      end

      candidates.concat(Dir.glob(AVRDUDE_GLOBS))
      candidates.uniq.find { |path| runnable_executable?(path) }
    end

    def avrdude_conf_for(avrdude)
      conf = File.expand_path("../etc/avrdude.conf", File.dirname(avrdude))
      File.file?(conf) ? conf : nil
    end
  end
end
