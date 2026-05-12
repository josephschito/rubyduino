# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestArduinoUnoAlias < Minitest::Test
  def test_arduino_uno_constants_compile
    sketch = <<~RUBY
      pin_mode(ArduinoUno::LED_BUILTIN, ArduinoUno::OUTPUT)
      digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::HIGH)
      delay_ms(10)
      digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::LOW)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "cst_ArduinoUno_OUTPUT"
    assert_includes c, "cst_ArduinoUno_HIGH"
    assert_includes c, "cst_ArduinoUno_LED_BUILTIN"
  end

  def test_legacy_arduino_uno_caps_still_works
    sketch = "digital_write(ArduinoUNO::LED_BUILTIN, ArduinoUNO::HIGH)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "cst_ArduinoUNO_LED_BUILTIN"
  end

  def test_constants_match_legacy_values
    file = File.read(File.expand_path("../lib/rubyduino/arduino_uno.rb", __dir__))
    # Both modules should declare LED_BUILTIN = 13
    led_decls = file.scan(/LED_BUILTIN\s*=\s*(\d+)/).flatten
    assert_equal 2, led_decls.length, "expected LED_BUILTIN in both modules"
    assert_equal led_decls.uniq, ["13"]
  end

  def test_avr_compile_with_uno_alias
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      pin_mode(ArduinoUno::LED_BUILTIN, ArduinoUno::OUTPUT)
      loop do
        digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::HIGH)
        sleep_ms(500)
        digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::LOW)
        sleep_ms(500)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
