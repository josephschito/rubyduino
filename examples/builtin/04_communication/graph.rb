# Graph
#
# Streams the value of A0 over serial as ASCII for plotting on the host.
#
# https://docs.arduino.cc/built-in-examples/communication/Graph/

serial_begin(9600)

loop do
  serial_println(analog_read(ArduinoUNO::A0))
  delay_ms(2)
end
