# switchCase2
#
# Lights one of five LEDs (pins 2..6) based on the incoming serial char a..e.
#
# https://docs.arduino.cc/built-in-examples/control-structures/SwitchCase2/

serial_begin(9600)

pin = 2
while pin < 7
  pin_mode(pin, ArduinoUNO::OUTPUT)
  pin += 1
end

loop do
  if serial_available > 0
    in_byte = serial_read

    case in_byte
    when ?a.ord
      digital_write(2, ArduinoUNO::HIGH)
    when ?b.ord
      digital_write(3, ArduinoUNO::HIGH)
    when ?c.ord
      digital_write(4, ArduinoUNO::HIGH)
    when ?d.ord
      digital_write(5, ArduinoUNO::HIGH)
    when ?e.ord
      digital_write(6, ArduinoUNO::HIGH)
    else
      pin = 2
      while pin < 7
        digital_write(pin, ArduinoUNO::LOW)
        pin += 1
      end
    end
  end
end
