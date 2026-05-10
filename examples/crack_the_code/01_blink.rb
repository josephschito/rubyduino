# Blink (one LED)
#
# Turns an LED on pin 12 of the ThinkerShield on for one second,
# then off for one second, forever.

LED_PIN = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)

loop do
  digital_write(LED_PIN, ArduinoUNO::HIGH)
  delay_ms(1000)
  digital_write(LED_PIN, ArduinoUNO::LOW)
  delay_ms(1000)
end
