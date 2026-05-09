# toneMultiple
#
# Plays notes in sequence on pins 6, 7, 8.
#
# https://docs.arduino.cc/built-in-examples/digital/toneMultiple/

loop do
  no_tone(8)
  tone(6, 440, 200)
  delay_ms(200)

  no_tone(6)
  tone(7, 494, 500)
  delay_ms(500)

  no_tone(7)
  tone(8, 523, 300)
  delay_ms(300)
end
