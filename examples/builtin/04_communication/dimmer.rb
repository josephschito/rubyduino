# Dimmer
#
# Brightens an LED on pin 9 from a single byte value sent over the serial port.
#
# https://docs.arduino.cc/built-in-examples/communication/Dimmer/

led_pin = 9

serial_begin(9600)
pin_mode(led_pin, ArduinoUNO::OUTPUT)

loop do
  if serial_available > 0
    brightness = serial_read
    analog_write(led_pin, brightness)
  end
end
