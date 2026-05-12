# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestStepper < Minitest::Test
  def test_codegen
    sketch = <<~RUBY
      stepper_begin(200, 8, 9, 10, 11)
      stepper_set_speed(60)
      stepper_step(100)
      stepper_step(-50)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[stepper_begin stepper_set_speed stepper_step].each do |fn|
      assert_includes c, "#{fn}(", "missing #{fn}"
    end
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      stepper_begin(200, 8, 9, 10, 11)
      stepper_set_speed(60)
      loop do
        stepper_step(200)
        sleep_ms(500)
        stepper_step(-200)
        sleep_ms(500)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
