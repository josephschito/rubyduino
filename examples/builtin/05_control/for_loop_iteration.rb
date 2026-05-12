# ForLoopIteration
#
# Walks LEDs on pins 2..7 forward and back.
#
# https://docs.arduino.cc/built-in-examples/control-structures/ForLoopIteration/

timer = 100

pin = 2
while pin < 8
  pin_mode(pin, ArduinoUNO::OUTPUT)
  pin += 1
end

loop do
  pin = 2
  while pin < 8
    digital_write(pin, ArduinoUNO::HIGH)
    delay_ms(timer)
    digital_write(pin, ArduinoUNO::LOW)
    pin += 1
  end

  pin = 7
  while pin >= 2
    digital_write(pin, ArduinoUNO::HIGH)
    delay_ms(timer)
    digital_write(pin, ArduinoUNO::LOW)
    pin -= 1
  end
end
