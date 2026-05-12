# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestWithoutInterrupts < Minitest::Test
  def test_block_form_compiles
    sketch = <<~RUBY
      x = 0
      without_interrupts do
        x = millis
        digital_write(13, 1)
      end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    # The block boundary expands to no_interrupts() ... interrupts() in C.
    assert_includes c, "no_interrupts("
    assert_includes c, "interrupts("
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      counter = 0
      loop do
        without_interrupts do
          counter = counter + 1
        end
        digital_write(13, counter & 1)
        sleep_ms(100)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
