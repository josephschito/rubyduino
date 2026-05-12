# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestNeoPixel < Minitest::Test
  HELPERS = %w[neopixel_begin neopixel_set_pixel neopixel_clear neopixel_show].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      neopixel_begin(6, 16)
      neopixel_set_pixel(0, 255, 0, 0)
      neopixel_set_pixel(1, 0, 255, 0)
      neopixel_show
      neopixel_clear
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      neopixel_begin(6, 8)
      loop do
        i = 0
        while i < 8
          neopixel_clear
          neopixel_set_pixel(i, 64, 0, 32)
          neopixel_show
          sleep_ms(120)
          i += 1
        end
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
