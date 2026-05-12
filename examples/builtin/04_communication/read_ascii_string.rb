# ReadASCIIString
#
# Parses comma-separated R,G,B integers ending with '\n' from serial,
# then drives a common-cathode RGB LED on pins 3/5/6 (inverted).
#
# https://docs.arduino.cc/built-in-examples/communication/ReadASCIIString/

red_pin = 3
green_pin = 5
blue_pin = 6

serial_begin(9600)
pin_mode(red_pin, ArduinoUNO::OUTPUT)
pin_mode(green_pin, ArduinoUNO::OUTPUT)
pin_mode(blue_pin, ArduinoUNO::OUTPUT)

loop do
  while serial_available > 0
    red = serial_parse_int
    green = serial_parse_int
    blue = serial_parse_int

    if serial_read == ?\n.ord
      red = 255 - constrain(red, 0, 255)
      green = 255 - constrain(green, 0, 255)
      blue = 255 - constrain(blue, 0, 255)

      analog_write(red_pin, red)
      analog_write(green_pin, green)
      analog_write(blue_pin, blue)

      serial_print(red, ArduinoUNO::HEX)
      serial_print(green, ArduinoUNO::HEX)
      serial_println(blue, ArduinoUNO::HEX)
    end
  end
end
