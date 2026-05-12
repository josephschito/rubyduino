# Calibration
#
# Captures min/max sensor readings during the first 5 seconds, then maps the
# live reading to 0–255 PWM on pin 9.
#
# https://docs.arduino.cc/built-in-examples/analog/Calibration/

sensor_pin = ArduinoUNO::A0
led_pin = 9

sensor_min = 1023
sensor_max = 0

pin_mode(13, ArduinoUNO::OUTPUT)
digital_write(13, ArduinoUNO::HIGH)

while millis < 5000
  sensor_value = analog_read(sensor_pin)
  sensor_max = sensor_value if sensor_value > sensor_max
  sensor_min = sensor_value if sensor_value < sensor_min
end

digital_write(13, ArduinoUNO::LOW)

loop do
  sensor_value = analog_read(sensor_pin)
  sensor_value = constrain(sensor_value, sensor_min, sensor_max)
  sensor_value = map_value(sensor_value, sensor_min, sensor_max, 0, 255)
  analog_write(led_pin, sensor_value)
end
