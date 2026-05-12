# 16x2 LCD "Hello, world!"
#
# Wiring (HD44780 in 4-bit mode, R/W to GND):
#   RS -> D12, EN -> D11, D4 -> D5, D5 -> D4, D6 -> D3, D7 -> D2

lcd_begin(12, 11, 5, 4, 3, 2, 16, 2)

lcd_print_str("Hello, world!")
lcd_set_cursor(0, 1)
lcd_print_str("rubyduino + LCD")

count = 0
loop do
  lcd_set_cursor(13, 1)
  lcd_print_int(count % 1000)
  lcd_write_char(32) # space
  count += 1
  sleep_ms(500)
end
