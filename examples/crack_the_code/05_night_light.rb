# Night light
#
# Reads the light sensor (LDR) on pin 4 and turns on the LED on pin 12
# whenever the room gets dark (sensor reads below 500).

SENSOR_PIN = 4
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(SENSOR_PIN, ArduinoUNO::INPUT)
serial_begin(9600)

loop do
  light_level = analog_read(SENSOR_PIN)
  serial_println(light_level)
  if light_level < 500
    digital_write(LED_PIN, ArduinoUNO::HIGH)
  else
    digital_write(LED_PIN, ArduinoUNO::LOW)
  end
end
