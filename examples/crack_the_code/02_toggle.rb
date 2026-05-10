# Toggle (latching button)
#
# Press the button on pin 7 once to turn the LED on, press again to
# turn it off. A short delay debounces the button press.

BUTTON_PIN = 7
LED_PIN    = 12

pin_mode(LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(BUTTON_PIN, ArduinoUNO::INPUT)

led_state = ArduinoUNO::LOW

loop do
  digital_write(LED_PIN, led_state)
  button_state = digital_read(BUTTON_PIN)
  if led_state == ArduinoUNO::HIGH
    if button_state == ArduinoUNO::HIGH
      led_state = ArduinoUNO::LOW
      delay_ms(400)
    end
  else
    if button_state == ArduinoUNO::HIGH
      led_state = ArduinoUNO::HIGH
      delay_ms(400)
    end
  end
end
