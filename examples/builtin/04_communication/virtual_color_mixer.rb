# VirtualColorMixer
#
# Streams three pot values (A0/A1/A2) as comma-separated ASCII over serial.
#
# https://docs.arduino.cc/built-in-examples/communication/VirtualColorMixer/

red_pin = ArduinoUNO::A0
green_pin = ArduinoUNO::A1
blue_pin = ArduinoUNO::A2

serial_begin(9600)

loop do
  serial_print(analog_read(red_pin))
  serial_print(",")
  serial_print(analog_read(green_pin))
  serial_print(",")
  serial_println(analog_read(blue_pin))
end
