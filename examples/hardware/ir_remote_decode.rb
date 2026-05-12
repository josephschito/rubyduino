# IR remote receiver (NEC protocol)
#
# Wire a TSOP38xx-style demodulator's data line to D2.
# Prints decoded 32-bit NEC frames as hex over serial.

IR_PIN = 2

serial_begin(9600)
serial_println("Point an IR remote at the receiver...")

loop do
  if ir_receive?(IR_PIN, 1000)
    cmd = ir_command
    serial_print("frame=0x")
    serial_print(cmd, ArduinoUNO::HEX)
    serial_print("  command_byte=0x")
    serial_println((cmd >> 16) & 0xFF, ArduinoUNO::HEX)
  end
end
