# Debounce
#
# Toggles an LED on each rising edge of a pushbutton, ignoring contact bounce.
#
# https://docs.arduino.cc/built-in-examples/digital/Debounce/

button_pin = 2
led_pin = 13

led_state = ArduinoUNO::HIGH
button_state = ArduinoUNO::LOW
last_button_state = ArduinoUNO::LOW
last_debounce_time = 0
debounce_delay = 50

pin_mode(button_pin, ArduinoUNO::INPUT)
pin_mode(led_pin, ArduinoUNO::OUTPUT)
digital_write(led_pin, led_state)

loop do
  reading = digital_read(button_pin)

  if reading != last_button_state
    last_debounce_time = millis
  end

  if (millis - last_debounce_time) > debounce_delay
    if reading != button_state
      button_state = reading
      if button_state == ArduinoUNO::HIGH
        led_state = led_state == ArduinoUNO::HIGH ? ArduinoUNO::LOW : ArduinoUNO::HIGH
      end
    end
  end

  digital_write(led_pin, led_state)
  last_button_state = reading
end
