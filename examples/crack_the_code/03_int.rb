# Variables (give pin numbers a name)
#
# Same as Blink, but the pin number is stored in a constant so the
# code is easier to read and change later.

LED = 12

pin_mode(LED, ArduinoUNO::OUTPUT)

loop do
  digital_write(LED, ArduinoUNO::HIGH)
  delay_ms(1000)
  digital_write(LED, ArduinoUNO::LOW)
  delay_ms(1000)
end
