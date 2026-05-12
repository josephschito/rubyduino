# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestLCD < Minitest::Test
  HELPERS = %w[lcd_begin lcd_clear lcd_home lcd_set_cursor lcd_write_char
               lcd_print_str lcd_print_int].freeze

  def test_codegen
    sketch = <<~RUBY
      lcd_begin(12, 11, 5, 4, 3, 2)
      lcd_print_str("hello")
      lcd_set_cursor(0, 1)
      lcd_print_int(42)
      lcd_home
      lcd_clear
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      lcd_begin(12, 11, 5, 4, 3, 2, 16, 2)
      lcd_print_str("rubyduino")
      lcd_set_cursor(0, 1)

      counter = 0
      loop do
        lcd_set_cursor(0, 1)
        lcd_print_str("count: ")
        lcd_print_int(counter)
        lcd_write_char(32) # space
        counter += 1
        sleep_ms(500)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
