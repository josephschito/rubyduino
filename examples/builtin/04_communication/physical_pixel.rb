# PhysicalPixel
#
# Toggles the on-board LED on incoming 'H' / 'L' bytes from the host.
#
# https://docs.arduino.cc/built-in-examples/communication/PhysicalPixel/

led_pin = 13

serial_begin(9600)
pin_mode(led_pin, ArduinoUNO::OUTPUT)

loop do
  if serial_available > 0
    incoming = serial_read
    if incoming == ?H.ord
      digital_write(led_pin, ArduinoUNO::HIGH)
    end
    if incoming == ?L.ord
      digital_write(led_pin, ArduinoUNO::LOW)
    end
  end
end
