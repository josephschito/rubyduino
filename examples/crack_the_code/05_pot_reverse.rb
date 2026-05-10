# Potentiometer (reverse action)
#
# Same as the analog-input demo, but the delay is the OPPOSITE of the
# pot reading: turning the pot UP makes the LED blink FASTER.

SENSOR_PIN = ArduinoUNO::A5
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(SENSOR_PIN, ArduinoUNO::INPUT)
serial_begin(9600)

loop do
  sensor_value = analog_read(SENSOR_PIN)
  delay_value  = 1023 - sensor_value

  digital_write(LED_PIN, ArduinoUNO::HIGH)
  delay_ms(delay_value)
  digital_write(LED_PIN, ArduinoUNO::LOW)
  delay_ms(delay_value)

  serial_print("The delay is: ")
  serial_print(delay_value)
  serial_print("   The pot value is: ")
  serial_println(sensor_value)
end
