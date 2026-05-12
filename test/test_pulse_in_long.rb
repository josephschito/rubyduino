# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestPulseInLong < Minitest::Test
  def test_codegen_default_timeout
    sketch = "d = pulse_in_long(7, 1)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    # Default timeout 1_000_000 reaches the wrapper.
    assert_match(/sp_pulse_in_long\(7LL, 1LL, 1000000LL\)/, c)
    assert_includes c, "pulse_in_timeout("
  end

  def test_codegen_explicit_timeout
    sketch = "d = pulse_in_long(7, 1, 5_000_000)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_match(/sp_pulse_in_long\(7LL, 1LL, 5000000LL\)/, c)
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      pin_mode(7, ArduinoUNO::INPUT)
      duration = pulse_in_long(7, ArduinoUNO::HIGH, 200_000)
      delay_ms(duration / 1000)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
