# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestAnalogReference < Minitest::Test
  def test_codegen_with_literal
    sketch = "analog_reference(3)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "analog_reference("
    assert_match(/sp_analog_reference\(3LL\)/, c)
  end

  def test_codegen_with_constant
    sketch = "analog_reference(ArduinoUNO::AREF_INTERNAL)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "cst_ArduinoUNO_AREF_INTERNAL"
    assert_includes c, "sp_analog_reference(cst_ArduinoUNO_AREF_INTERNAL)"
    # Constant initializer assigns the right value
    assert_match(/cst_ArduinoUNO_AREF_INTERNAL\s*=\s*3LL;/, c)
  end

  def test_constants_in_arduino_uno_rb_match_atmega328p_refs_bits
    # ATmega328P REFS bits: External=00, Default(AVcc)=01, Internal 1.1V=11
    contents = File.read(File.expand_path("../lib/rubyduino/arduino_uno.rb", __dir__))
    assert_match(/AREF_EXTERNAL\s*=\s*0\b/, contents)
    assert_match(/AREF_DEFAULT\s*=\s*1\b/, contents)
    assert_match(/AREF_INTERNAL\s*=\s*3\b/, contents)
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      analog_reference(ArduinoUNO::AREF_INTERNAL)
      v = analog_read(ArduinoUNO::A0)
      digital_write(13, v > 512 ? 1 : 0)

      analog_reference(ArduinoUNO::AREF_DEFAULT)
      v2 = analog_read(ArduinoUNO::A1)
      digital_write(12, v2 > 512 ? 1 : 0)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
