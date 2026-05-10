# Button
#
# Reads the pushbutton on pin 7 of the ThinkerShield. While the button
# is held down, the LED on pin 12 is on; otherwise it's off.

BUTTON_PIN = 7
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(BUTTON_PIN, ArduinoUNO::INPUT)

loop do
  button_state = digital_read(BUTTON_PIN)
  if button_state == ArduinoUNO::HIGH
    digital_write(LED_PIN, ArduinoUNO::HIGH)
  else
    digital_write(LED_PIN, ArduinoUNO::LOW)
  end
end
