#!/usr/bin/env ruby
# Arduino UNO codegen layer for Spinel.
#
# This file intentionally leaves spinel_codegen.rb unchanged. Spinel's codegen
# file is CLI-oriented, so we load only its Compiler definition and keep the
# same AST-file input/output-file flow as the upstream footer.

module SpinelArduinoCodegen
  ROOT = File.expand_path("../..", __dir__)
  SPINEL_ROOT = File.join(ROOT, "vendor/spinel")

  # Load Spinel's Compiler class without executing its CLI footer. The split
  # marker isolates the class definitions from the bottom-of-file `Compiler.new`
  # entry point so we can replace it with our own argv handling below.
  def self.load_spinel_compiler
    path = File.join(SPINEL_ROOT, "spinel_codegen.rb")
    source = File.read(path)
    marker = "\n# ---- Main ----\n"
    split_at = source.index(marker)
    unless split_at
      warn "spinel_arduino_codegen: cannot find codegen main marker"
      exit(1)
    end

    TOPLEVEL_BINDING.eval(source[0...split_at], path)
  end
end

SpinelArduinoCodegen.load_spinel_compiler

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

    if arg_ids.length == 1
      arg = arg_ids.first
      fn = arduino_serial_print_func(arg, newline)
      return "(" + fn + "(" + compile_expr(arg) + "), (mrb_int)0)"
    end

    if arg_ids.length == 2
      value_arg = arg_ids[0]
      base_or_dec_arg = arg_ids[1]

      if infer_type(value_arg) == "float"
        prefix = newline ? "serial_println_float" : "serial_print_float"
        return "(" + prefix + "((double)(" + compile_expr(value_arg) + "), (uint8_t)(" + compile_expr(base_or_dec_arg) + ")), (mrb_int)0)"
      end

      base_fn = arduino_base_print_func(base_or_dec_arg, newline)
      return nil unless base_fn

      return "(" + base_fn + "((uint32_t)(" + compile_expr(value_arg) + ")), (mrb_int)0)"
    end

    nil
  end

  def arduino_serial_print_func(arg, newline)
    if infer_type(arg) == "string"
      return newline ? "serial_println_str" : "serial_print_str"
    end
    if infer_type(arg) == "float"
      return newline ? "serial_println_float_default" : "serial_print_float_default"
    end

    newline ? "serial_println_int" : "serial_print_int"
  end

  def arduino_base_print_func(base_arg, newline)
    return nil unless integer_literal_node?(base_arg)
    case @nd_value[base_arg].to_i
    when 2  then newline ? "serial_println_bin" : "serial_print_bin"
    when 8  then newline ? "serial_println_oct" : "serial_print_oct"
    when 10 then newline ? "serial_println_int" : "serial_print_int"
    when 16 then newline ? "serial_println_hex" : "serial_print_hex"
    end
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

    if integer_literal_node?(left) && integer_literal_node?(right)
      first = @nd_value[left].to_i
      last = @nd_value[right].to_i
      return "0" if last < first

      @needs_rand = 1
      span = last - first + 1
      return "((mrb_int)(#{first} + (rand() % #{span})))"
    end

    @needs_rand = 1
    left_c = compile_expr(left)
    right_c = compile_expr(right)
    "((mrb_int)random_range((int32_t)(#{left_c}), (int32_t)(#{right_c}) + 1))"
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

compiler = Compiler.new
compiler.read_text_ast(File.read(ast_file))
compiler.compile

result = compiler.build_output
if out_file
  File.write(out_file, result)
else
  print result
end
