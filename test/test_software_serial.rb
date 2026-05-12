# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestSoftwareSerial < Minitest::Test
  def test_codegen
    sketch = <<~RUBY
      soft_serial_begin(2, 3, 9600)
      soft_serial_print_str("AT\\r\\n")
      b = soft_serial_read
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[soft_serial_begin soft_serial_print_str soft_serial_write soft_serial_read].each do |fn|
      assert_includes c, "#{fn}(", "missing #{fn}"
    end
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      soft_serial_begin(2, 3, 9600)
      serial_begin(9600)

      loop do
        soft_serial_print_str("ping\\n")
        b = soft_serial_read
        if b != -1
          serial_print("got: ")
          serial_println(b)
        end
        sleep_ms(1000)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
