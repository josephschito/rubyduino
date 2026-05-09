# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestYield < Minitest::Test
  def test_codegen
    sketch = <<~RUBY
      loop do
        arduino_yield
        delay_ms(100)
      end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "arduino_yield("
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      i = 0
      while i < 1000
        arduino_yield
        i = i + 1
      end
      digital_write(13, 1)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
