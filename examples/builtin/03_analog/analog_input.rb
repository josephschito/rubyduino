# AnalogInput
#
# Blinks LED on pin 13 with the on/off duration set by a pot on A0.
#
# https://docs.arduino.cc/built-in-examples/analog/AnalogInput/

sensor_pin = ArduinoUNO::A0
led_pin = 13

pin_mode(led_pin, ArduinoUNO::OUTPUT)

loop do
  sensor_value = analog_read(sensor_pin)
  digital_write(led_pin, ArduinoUNO::HIGH)
  delay_ms(sensor_value)
  digital_write(led_pin, ArduinoUNO::LOW)
  delay_ms(sensor_value)
end
