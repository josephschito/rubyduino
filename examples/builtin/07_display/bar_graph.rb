# BarGraph
#
# Lights a bar of 10 LEDs (pins 2–11) proportional to a pot reading on A0.
#
# https://docs.arduino.cc/built-in-examples/display/BarGraph/

analog_pin = ArduinoUNO::A0
led_count = 10
led_pins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

i = 0
while i < led_count
  pin_mode(led_pins[i], ArduinoUNO::OUTPUT)
  i += 1
end

loop do
  sensor_reading = analog_read(analog_pin)
  led_level = map_value(sensor_reading, 0, 1023, 0, led_count)

  i = 0
  while i < led_count
    if i < led_level
      digital_write(led_pins[i], ArduinoUNO::HIGH)
    else
      digital_write(led_pins[i], ArduinoUNO::LOW)
    end
    i += 1
  end
end
