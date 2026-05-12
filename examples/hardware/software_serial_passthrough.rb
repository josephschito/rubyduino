# SoftwareSerial passthrough
#
# Echoes bytes between hardware Serial (USB) and a SoftwareSerial port
# on RX=D2 / TX=D3 — useful for talking to a GPS/GSM/ESP8266 module
# while watching traffic from your laptop.

soft_serial_begin(2, 3, 9600)
serial_begin(9600)

loop do
  b = soft_serial_read
  if b != -1
    serial_write(b)
  end

  if serial_available > 0
    soft_serial_write(serial_read)
  end
end
