# DigitalInputPullup
#
# Uses INPUT_PULLUP on pin 2; lights LED on pin 13 when the button is pressed.
#
# https://docs.arduino.cc/built-in-examples/digital/InputPullupSerial/

serial_begin(9600)
pin_mode(2, ArduinoUNO::INPUT_PULLUP)
pin_mode(13, ArduinoUNO::OUTPUT)

loop do
  sensor_val = digital_read(2)
  serial_println(sensor_val)

  if sensor_val == ArduinoUNO::HIGH
    digital_write(13, ArduinoUNO::LOW)
  else
    digital_write(13, ArduinoUNO::HIGH)
  end
end
