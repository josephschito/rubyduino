# RowColumnScanning
#
# Scans an 8x8 LED matrix and draws a cursor whose position is set by two
# pots on A0/A1.  pixels[][] is flattened to a 1D array indexed by row*8+col.
#
# https://docs.arduino.cc/built-in-examples/display/RowColumnScanning/

row_pins = [2, 7, 19, 5, 13, 18, 12, 16]
col_pins = [6, 11, 10, 3, 17, 4, 8, 9]

# Flattened 8x8 pixel buffer; index = row * 8 + col
pixels = Array.new(64, ArduinoUNO::HIGH)

x = 5
y = 5

i = 0
while i < 8
  pin_mode(col_pins[i], ArduinoUNO::OUTPUT)
  pin_mode(row_pins[i], ArduinoUNO::OUTPUT)
  digital_write(col_pins[i], ArduinoUNO::HIGH)
  i += 1
end

loop do
  # readSensors
  pixels[x * 8 + y] = ArduinoUNO::HIGH
  x = 7 - map_value(analog_read(ArduinoUNO::A0), 0, 1023, 0, 7)
  y = map_value(analog_read(ArduinoUNO::A1), 0, 1023, 0, 7)
  pixels[x * 8 + y] = ArduinoUNO::LOW

  # refreshScreen
  this_row = 0
  while this_row < 8
    digital_write(row_pins[this_row], ArduinoUNO::HIGH)

    this_col = 0
    while this_col < 8
      this_pixel = pixels[this_row * 8 + this_col]
      digital_write(col_pins[this_col], this_pixel)
      if this_pixel == ArduinoUNO::LOW
        digital_write(col_pins[this_col], ArduinoUNO::HIGH)
      end
      this_col += 1
    end

    digital_write(row_pins[this_row], ArduinoUNO::LOW)
    this_row += 1
  end
end
