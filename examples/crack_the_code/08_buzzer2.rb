# Buzzer (alternating two tones)
#
# Plays a low tone, then a high tone, half a second each, forever.
# Sounds like a simple siren.

LOW_TONE   = 400
HIGH_TONE  = 600
BUZZER_PIN = 3

pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)

loop do
  tone(BUZZER_PIN, LOW_TONE, 500)
  delay_ms(500)
  tone(BUZZER_PIN, HIGH_TONE, 500)
  delay_ms(500)
end
