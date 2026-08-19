#!/usr/bin/env ruby
# Arduino UNO codegen layer for Spinel.
#
# This file intentionally leaves Spinel's analyzer and code generator unchanged.
# It runs the upstream analysis phase, then loads only the Compiler definition
# from the CLI-oriented code generator before applying the Arduino extensions.

require "rbconfig"
require "tempfile"

ROOT = File.expand_path("../..", __dir__)
SPINEL_ROOT = File.join(ROOT, "vendor/spinel")

def load_spinel_compiler
  path = File.join(SPINEL_ROOT, "spinel_codegen.rb")
  source = File.read(path)
  marker = "\n# ---- Main (codegen) ----\n"
  split_at = source.index(marker)
  unless split_at
    warn "spinel_arduino_codegen: cannot find codegen main marker"
    exit(1)
  end

  TOPLEVEL_BINDING.eval(source[0...split_at], path)
end

load_spinel_compiler

module SpinelArduinoCodegen
  def compile_no_recv_call_expr(nid, mname)
    case mname
    when "rand"
      arduino_rand = compile_arduino_rand(nid)
      return arduino_rand if arduino_rand

      super
    when "serial_print"
      arduino_serial_print = compile_arduino_serial_print(nid, false)
      return arduino_serial_print if arduino_serial_print

      super
    when "serial_println"
      arduino_serial_print = compile_arduino_serial_print(nid, true)
      return arduino_serial_print if arduino_serial_print

      super
    else
      super
    end
  end

  private

  def compile_arduino_serial_print(nid, newline)
    args_id = @nd_arguments[nid]
    return nil if args_id < 0

    arg_ids = get_args(args_id)
    return nil unless arg_ids.length == 1

    arg = arg_ids.first
    fn = arduino_serial_print_func(arg, newline)
    "(" + fn + "(" + compile_expr(arg) + "), (mrb_int)0)"
  end

  def arduino_serial_print_func(arg, newline)
    if infer_type(arg) == "string"
      return newline ? "serial_println_str" : "serial_print_str"
    end

    newline ? "serial_println_int" : "serial_print_int"
  end

  def compile_arduino_rand(nid)
    args_id = @nd_arguments[nid]
    return nil if args_id < 0

    arg_ids = get_args(args_id)
    return nil unless arg_ids.length == 1

    arg = arg_ids.first
    return nil unless @nd_type[arg] == "RangeNode"

    left = @nd_left[arg]
    right = @nd_right[arg]
    return nil unless integer_literal_node?(left) && integer_literal_node?(right)

    first = @nd_value[left].to_i
    last = @nd_value[right].to_i
    return "0" if last < first

    @needs_rand = 1
    span = last - first + 1
    "((mrb_int)(#{first} + (rand() % #{span})))"
  end

  def integer_literal_node?(nid)
    nid && nid >= 0 && @nd_type[nid] == "IntegerNode"
  end
end

Compiler.prepend(SpinelArduinoCodegen)

ast_file = ARGV[0]
out_file = ARGV[1]

if ast_file.nil?
  warn "Usage: ruby spinel_arduino_codegen.rb ast.txt output.c"
  exit(1)
end

analyzer = File.join(SPINEL_ROOT, "spinel_analyze.rb")
Tempfile.create(["spinel-analysis", ".ir"]) do |ir_file|
  ir_file.close
  abort "spinel_arduino_codegen: analysis failed" unless system(RbConfig.ruby, analyzer, ast_file, ir_file.path)

  compiler = Compiler.new
  compiler.read_text_ast(File.read(ast_file))
  compiler.load_analysis_buf(File.read(ir_file.path))
  compiler.generate_code

  result = compiler.build_output
  if out_file
    File.write(out_file, result)
  else
    print result
  end
end
