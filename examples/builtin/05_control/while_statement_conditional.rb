# WhileStatementConditional
#
# Calibrates a sensor on A0 while a button on pin 2 is pressed, then maps the
# live reading to PWM on pin 9 using the captured min/max.
#
# https://docs.arduino.cc/built-in-examples/control-structures/WhileStatementConditional/

sensor_pin = ArduinoUNO::A0
led_pin = 9
indicator_led_pin = 13
button_pin = 2

sensor_min = 1023
sensor_max = 0

pin_mode(indicator_led_pin, ArduinoUNO::OUTPUT)
pin_mode(led_pin, ArduinoUNO::OUTPUT)
pin_mode(button_pin, ArduinoUNO::INPUT)

loop do
  while digital_read(button_pin) == ArduinoUNO::HIGH
    digital_write(indicator_led_pin, ArduinoUNO::HIGH)
    sensor_value = analog_read(sensor_pin)
    sensor_max = sensor_value if sensor_value > sensor_max
    sensor_min = sensor_value if sensor_value < sensor_min
  end

  digital_write(indicator_led_pin, ArduinoUNO::LOW)

  sensor_value = analog_read(sensor_pin)
  sensor_value = map_value(sensor_value, sensor_min, sensor_max, 0, 255)
  sensor_value = constrain(sensor_value, 0, 255)
  analog_write(led_pin, sensor_value)
end
