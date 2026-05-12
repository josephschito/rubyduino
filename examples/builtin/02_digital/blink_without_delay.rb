# BlinkWithoutDelay
#
# Blinks the on-board LED using millis() so other code can run alongside it.
#
# https://docs.arduino.cc/built-in-examples/digital/BlinkWithoutDelay/

led_pin = ArduinoUNO::LED_BUILTIN
led_state = ArduinoUNO::LOW
previous_millis = 0
interval = 1000

pin_mode(led_pin, ArduinoUNO::OUTPUT)

loop do
  current_millis = millis

  if current_millis - previous_millis >= interval
    previous_millis = current_millis
    led_state = led_state == ArduinoUNO::LOW ? ArduinoUNO::HIGH : ArduinoUNO::LOW
    digital_write(led_pin, led_state)
  end
end
