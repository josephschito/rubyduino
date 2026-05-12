# Arrays
#
# Cycles a non-contiguous list of LED pins forward and back.
#
# https://docs.arduino.cc/built-in-examples/control-structures/Arrays/

timer = 100
led_pins = [2, 7, 4, 6, 5, 3]
pin_count = 6

i = 0
while i < pin_count
  pin_mode(led_pins[i], ArduinoUNO::OUTPUT)
  i += 1
end

loop do
  i = 0
  while i < pin_count
    digital_write(led_pins[i], ArduinoUNO::HIGH)
    delay_ms(timer)
    digital_write(led_pins[i], ArduinoUNO::LOW)
    i += 1
  end

  i = pin_count - 1
  while i >= 0
    digital_write(led_pins[i], ArduinoUNO::HIGH)
    delay_ms(timer)
    digital_write(led_pins[i], ArduinoUNO::LOW)
    i -= 1
  end
end
