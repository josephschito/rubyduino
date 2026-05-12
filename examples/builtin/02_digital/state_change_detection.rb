# StateChangeDetection
#
# Counts button press edges; lights an LED every fourth press.
#
# https://docs.arduino.cc/built-in-examples/digital/StateChangeDetection/

button_pin = 2
led_pin = 13

button_push_counter = 0
button_state = 0
last_button_state = 0

pin_mode(button_pin, ArduinoUNO::INPUT)
pin_mode(led_pin, ArduinoUNO::OUTPUT)
serial_begin(9600)

loop do
  button_state = digital_read(button_pin)

  if button_state != last_button_state
    if button_state == ArduinoUNO::HIGH
      button_push_counter += 1
      serial_println("on")
      serial_print("number of button pushes: ")
      serial_println(button_push_counter)
    else
      serial_println("off")
    end
    delay_ms(50)
  end

  last_button_state = button_state

  if button_push_counter % 4 == 0
    digital_write(led_pin, ArduinoUNO::HIGH)
  else
    digital_write(led_pin, ArduinoUNO::LOW)
  end
end
