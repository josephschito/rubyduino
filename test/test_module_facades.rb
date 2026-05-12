# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestModuleFacades < Minitest::Test
  def test_pin_facade_compiles
    sketch = <<~RUBY
      Pin.mode(13, ArduinoUno::OUTPUT)
      Pin.high(13)
      Pin.low(12)
      Pin.write(11, 1)
      v = Pin.read(2)
      digital_write(13, 1) if Pin.high?(2)
      digital_write(12, 1) if Pin.low?(3)
      v2 = Pin.analog_read(ArduinoUno::A0)
      Pin.analog_write(9, 128)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[sp_Pin_cls_mode sp_Pin_cls_high sp_Pin_cls_low sp_Pin_cls_read
       sp_Pin_cls_high_p sp_Pin_cls_low_p sp_Pin_cls_analog_read sp_Pin_cls_analog_write].each do |sym|
      assert_includes c, sym, "missing #{sym}"
    end
  end

  def test_serial_facade_compiles
    sketch = <<~RUBY
      Serial.begin(9600)
      Serial.timeout = 500
      t = Serial.timeout
      n = Serial.available
      digital_write(13, 1) if Serial.available?
      Serial.println_str("hello")
      Serial.println_int(42)
      Serial.println_hex(0xABCD)
      x = Serial.read
      digital_write(12, 1) if Serial.find?("OK")
      Serial.flush
      Serial.end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "sp_Serial_cls_begin"
    assert_includes c, "sp_Serial_cls_timeout_eq"
    assert_includes c, "sp_Serial_cls_available_p"
    assert_includes c, "sp_Serial_cls_println_str"
    assert_includes c, "sp_Serial_cls_find_p"
  end

  def test_eeprom_facade_compiles
    sketch = <<~RUBY
      Eeprom.write(0, 0xAB)
      v = Eeprom.read(0)
      Eeprom.update(1, 7)
      total = Eeprom.length
      Eeprom.write_int(4, -100_000)
      n = Eeprom.read_int(4)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[sp_Eeprom_cls_write sp_Eeprom_cls_read sp_Eeprom_cls_update sp_Eeprom_cls_length
       sp_Eeprom_cls_write_int sp_Eeprom_cls_read_int].each do |sym|
      assert_includes c, sym
    end
  end

  def test_spi_facade_compiles
    sketch = <<~RUBY
      Spi.begin
      Spi.data_mode = ArduinoUno::SPI_MODE0
      Spi.clock_divider = ArduinoUno::SPI_CLOCK_DIV4
      Spi.bit_order = ArduinoUno::MSBFIRST
      r = Spi.transfer(0x9F)
      r2 = Spi.transfer16(0x1234)
      Spi.end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[sp_Spi_cls_begin sp_Spi_cls_data_mode_eq sp_Spi_cls_clock_divider_eq sp_Spi_cls_bit_order_eq
       sp_Spi_cls_transfer sp_Spi_cls_transfer16 sp_Spi_cls_end].each do |sym|
      assert_includes c, sym
    end
  end

  def test_wire_facade_compiles
    sketch = <<~RUBY
      Wire.begin
      Wire.clock = 100_000
      Wire.transmit(0x68)
      Wire.write(0x6B)
      Wire.write(0)
      err = Wire.end_transmission
      n = Wire.request_from(0x68, 6)
      while Wire.available?
        b = Wire.read
      end
      Wire.end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[sp_Wire_cls_begin sp_Wire_cls_clock_eq sp_Wire_cls_transmit sp_Wire_cls_write
       sp_Wire_cls_end_transmission sp_Wire_cls_request_from sp_Wire_cls_available_p sp_Wire_cls_read].each do |sym|
      assert_includes c, sym
    end
  end

  def test_servo_facade_compiles
    sketch = <<~RUBY
      Servo.attach(9)
      Servo.angle = 90
      a = Servo.angle
      Servo.microseconds = 1500
      us = Servo.microseconds
      digital_write(13, 1) if Servo.attached?
      Servo.detach
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[sp_Servo_cls_attach sp_Servo_cls_angle sp_Servo_cls_angle_eq sp_Servo_cls_microseconds
       sp_Servo_cls_microseconds_eq sp_Servo_cls_attached_p sp_Servo_cls_detach].each do |sym|
      assert_includes c, sym
    end
  end

  def test_full_facade_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      Serial.begin(9600)
      Pin.mode(13, ArduinoUno::OUTPUT)

      Eeprom.write(0, 0xAB)
      byte = Eeprom.read(0)

      Spi.begin
      Spi.data_mode = ArduinoUno::SPI_MODE0
      reply = Spi.transfer(0x9F)
      Spi.end

      Wire.begin
      Wire.clock = 100_000
      Wire.transmit(0x68)
      Wire.write(0x6B)
      Wire.end_transmission

      Servo.attach(9)
      Servo.angle = 90

      loop do
        Pin.high(13)
        sleep_ms(500)
        Pin.low(13)
        sleep_ms(500)
      end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
