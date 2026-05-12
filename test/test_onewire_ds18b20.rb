# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestOneWireDS18B20 < Minitest::Test
  HELPERS = %w[onewire_reset onewire_write_byte onewire_read_byte
               ds18b20_request_temperature ds18b20_read_temperature_x10].freeze

  def test_codegen
    sketch = <<~RUBY
      pin = 4
      ok = onewire_reset?(pin)
      onewire_write_byte(pin, 0xCC)
      b = onewire_read_byte(pin)
      ds18b20_request_temperature(pin)
      sleep_ms(750)
      t = ds18b20_read_temperature_x10(pin)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      pin = 4

      loop do
        if ds18b20_request_temperature(pin) == 1
          sleep_ms(750)
          t = ds18b20_read_temperature_x10(pin)
          serial_print("temp=")
          serial_print(t / 10)
          serial_print(".")
          serial_println(t % 10)
        else
          serial_println("no DS18B20")
        end
        sleep_ms(2000)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
