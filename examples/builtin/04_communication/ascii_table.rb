# ASCIITable
#
# Prints byte values 33–126 in raw, decimal, hex, octal, and binary forms.
#
# https://docs.arduino.cc/built-in-examples/communication/ASCIITable/

serial_begin(9600)
serial_println("ASCII Table ~ Character Map")

this_byte = 33

loop do
  serial_write(this_byte)

  serial_print(", dec: ")
  serial_print(this_byte)

  serial_print(", hex: ")
  serial_print(this_byte, ArduinoUNO::HEX)

  serial_print(", oct: ")
  serial_print(this_byte, ArduinoUNO::OCT)

  serial_print(", bin: ")
  serial_println(this_byte, ArduinoUNO::BIN)

  if this_byte == 126
    loop do
      # idle once we hit '~'
    end
  end

  this_byte += 1
end
