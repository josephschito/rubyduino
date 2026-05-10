# Toggle (latching button, two-check version)
#
# Same idea as `toggle`, but checks the button twice each loop — once
# to turn the LED off, again to turn it on. Demonstrates how the order
# of checks matters when a button stays pressed.

BUTTON_PIN = 7
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(BUTTON_PIN, ArduinoUNO::INPUT)

led_state = ArduinoUNO::LOW

loop do
  digital_write(LED_PIN, led_state)

  button_state = digital_read(BUTTON_PIN)
  if button_state == ArduinoUNO::HIGH && led_state == ArduinoUNO::HIGH
    led_state = ArduinoUNO::LOW
    delay_ms(300)
  end

  button_state = digital_read(BUTTON_PIN)
  if button_state == ArduinoUNO::HIGH && led_state == ArduinoUNO::LOW
    led_state = ArduinoUNO::HIGH
    delay_ms(300)
  end
end
