# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestDHT < Minitest::Test
  def test_codegen
    sketch = <<~RUBY
      err = dht_read(7, DHT22)
      if err == 0
        t = dht_temperature_x10
        h = dht_humidity_x10
      end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "dht_read("
    assert_includes c, "dht_temperature_x10("
    assert_includes c, "dht_humidity_x10("
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      pin = 7

      loop do
        if dht_read?(pin, DHT22)
          t = dht_temperature_x10
          h = dht_humidity_x10
          serial_print("temp=")
          serial_print(t / 10)
          serial_print(".")
          serial_print(t % 10)
          serial_print("C humid=")
          serial_print(h / 10)
          serial_print(".")
          serial_println(h % 10)
        else
          serial_println("dht read failed")
        end
        sleep_ms(2000)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
