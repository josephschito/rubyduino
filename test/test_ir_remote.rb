# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestIRRemote < Minitest::Test
  def test_codegen
    sketch = <<~RUBY
      pin = 2
      if ir_receive?(pin, 50)
        cmd = ir_command
        digital_write(13, 1) if cmd == 0xFF02FD
      end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "ir_receive("
    assert_includes c, "ir_command("
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      pin = 2

      loop do
        if ir_receive?(pin, 100)
          serial_print("cmd=0x")
          serial_println(ir_command, ArduinoUNO::HEX)
        end
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
