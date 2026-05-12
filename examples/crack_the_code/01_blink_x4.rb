# Blink (four LEDs)
#
# Lights up the four LEDs on the ThinkerShield (pins 9, 10, 11, 12)
# all at once for one second, then off for one second, forever.

PINS = [9, 10, 11, 12]

PINS.each { |p| pin_mode(p, ArduinoUNO::OUTPUT) }

loop do
  PINS.each { |p| digital_write(p, ArduinoUNO::HIGH) }
  delay_ms(1000)
  PINS.each { |p| digital_write(p, ArduinoUNO::LOW) }
  delay_ms(1000)
end
