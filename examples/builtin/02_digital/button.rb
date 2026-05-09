# Button
#
# Lights an LED when a pushbutton is pressed.
#
# https://docs.arduino.cc/built-in-examples/digital/Button/

button_pin = 2
led_pin = 13

pin_mode(led_pin, ArduinoUNO::OUTPUT)
pin_mode(button_pin, ArduinoUNO::INPUT)

loop do
  button_state = digital_read(button_pin)

  if button_state == ArduinoUNO::HIGH
    digital_write(led_pin, ArduinoUNO::HIGH)
  else
    digital_write(led_pin, ArduinoUNO::LOW)
  end
end
