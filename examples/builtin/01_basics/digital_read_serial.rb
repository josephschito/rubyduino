# DigitalReadSerial
#
# Reads a digital input on pin 2, prints the result to the Serial Monitor.
#
# https://docs.arduino.cc/built-in-examples/basics/DigitalReadSerial/

push_button = 2

serial_begin(9600)
pin_mode(push_button, ArduinoUNO::INPUT)

loop do
  button_state = digital_read(push_button)
  serial_println(button_state)
  delay_ms(1)
end
