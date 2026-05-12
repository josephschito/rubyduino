# frozen_string_literal: true

require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

module CompileHelper
  ROOT = File.expand_path("../..", __dir__)
  SPINEL_DIR = File.join(ROOT, "vendor/spinel")
  RUBYDUINO_DIR = File.join(ROOT, "lib/rubyduino")
  PARSE_BIN = File.join(SPINEL_DIR, "spinel_parse")
  CODEGEN_RB = File.join(RUBYDUINO_DIR, "spinel_arduino_codegen.rb")
  ARDUINO_UNO_RB = File.join(RUBYDUINO_DIR, "arduino_uno.rb")
  ENTRY_C = File.join(RUBYDUINO_DIR, "arduino_entry.c")

  module_function

  def parser_available?
    File.executable?(PARSE_BIN)
  end

  def avr_gcc_available?
    !which("avr-gcc").nil?
  end

  def avr_objdump_available?
    !which("avr-objdump").nil?
  end

  def simavr_available?
    !which("simavr").nil?
  end

  def which(name)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |dir|
      path = File.join(dir, name)
      return path if File.file?(path) && File.executable?(path)
    end
    nil
  end

  def compile_ruby_to_c(sketch)
    raise "spinel_parse not built; run make in vendor/spinel" unless parser_available?

    Dir.mktmpdir("rubyduino_test") do |dir|
      source = File.join(dir, "sketch.rb")
      ast = File.join(dir, "sketch.ast")
      out_c = File.join(dir, "sketch.c")

      header = File.read(ARDUINO_UNO_RB)
      File.write(source, "#{header}\n#{sketch}")

      run!(PARSE_BIN, source, ast)
      run!(RbConfig.ruby, CODEGEN_RB, ast, out_c)

      File.read(out_c)
    end
  end

  def compile_ruby_to_avr_obj(sketch, mcu: "atmega328p")
    raise "avr-gcc not installed" unless avr_gcc_available?

    c_code = compile_ruby_to_c(sketch)

    Dir.mktmpdir("rubyduino_avr") do |dir|
      c_file = File.join(dir, "sketch.c")
      obj_file = File.join(dir, "sketch.o")
      File.write(c_file, c_code)

      flags = ["-Os", "-DF_CPU=16000000UL", "-mmcu=#{mcu}",
               "-I#{RUBYDUINO_DIR}", "-I#{File.join(SPINEL_DIR, "lib")}",
               "-Dmain=sp_arduino_user_main"]
      run!("avr-gcc", *flags, "-c", c_file, "-o", obj_file)

      yield obj_file, c_file, c_code if block_given?
      File.binread(obj_file)
    end
  end

  def compile_ruby_to_avr_elf(sketch, mcu: "atmega328p")
    raise "avr-gcc not installed" unless avr_gcc_available?

    c_code = compile_ruby_to_c(sketch)

    Dir.mktmpdir("rubyduino_elf") do |dir|
      c_file = File.join(dir, "sketch.c")
      app_obj = File.join(dir, "sketch.o")
      entry_obj = File.join(dir, "entry.o")
      elf = File.join(dir, "sketch.elf")
      File.write(c_file, c_code)

      flags = ["-Os", "-DF_CPU=16000000UL", "-mmcu=#{mcu}",
               "-I#{RUBYDUINO_DIR}", "-I#{File.join(SPINEL_DIR, "lib")}"]
      run!("avr-gcc", *flags, "-Dmain=sp_arduino_user_main", "-c", c_file, "-o", app_obj)
      run!("avr-gcc", *flags, "-c", ENTRY_C, "-o", entry_obj)
      run!("avr-gcc", "-Os", "-DF_CPU=16000000UL", "-mmcu=#{mcu}",
           app_obj, entry_obj, "-o", elf)

      result = { elf: File.binread(elf), c_code: c_code }
      if block_given?
        yield elf, c_file, c_code
      end
      result
    end
  end

  def avr_objdump_disassembly(elf_path)
    out, status = Open3.capture2e("avr-objdump", "-d", elf_path)
    raise "avr-objdump failed: #{out}" unless status.success?
    out
  end

  def avr_nm_symbols(obj_path)
    out, status = Open3.capture2e("avr-nm", obj_path)
    raise "avr-nm failed: #{out}" unless status.success?
    out
  end

  def run_native_program(c_source, defines: [])
    raise "no host C compiler" unless which("clang") || which("cc")

    Dir.mktmpdir("rubyduino_native") do |dir|
      c_file = File.join(dir, "test.c")
      bin = File.join(dir, "test")
      File.write(c_file, c_source)

      cc = which("clang") || which("cc")
      flags = defines.map { |d| "-D#{d}" }
      run!(cc, "-O0", "-std=c11", *flags, c_file, "-o", bin)

      out, status = Open3.capture2e(bin)
      [out, status.success?]
    end
  end

  def run!(*cmd)
    out, status = Open3.capture2e(*cmd)
    raise "#{cmd.join(" ")} failed:\n#{out}" unless status.success?
    out
  end
end
