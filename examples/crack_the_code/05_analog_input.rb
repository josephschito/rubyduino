# Analog input (potentiometer controls blink speed)
#
# Reads the potentiometer on A5 (0..1023) and uses that value as the
# delay between LED-on and LED-off. Turn the pot to speed up or slow
# down the blink.

SENSOR_PIN = ArduinoUNO::A5
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
serial_begin(9600)

loop do
  sensor_value = analog_read(SENSOR_PIN)
  digital_write(LED_PIN, ArduinoUNO::HIGH)
  delay_ms(sensor_value)
  digital_write(LED_PIN, ArduinoUNO::LOW)
  delay_ms(sensor_value)
  serial_print("The sensor value is: ")
  serial_println(sensor_value)
end
