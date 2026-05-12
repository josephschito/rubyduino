# Buzzer (sweep up and down)
#
# Sweeps the buzzer's pitch from 200 Hz up to 700 Hz, then back down,
# in steps of 2 Hz. Sounds like a UFO landing.

BUZZER_PIN = 3

pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)

loop do
  i = 200
  while i < 700
    tone(BUZZER_PIN, i, 10)
    delay_ms(10)
    i += 2
  end
  i = 701
  while i > 200
    tone(BUZZER_PIN, i, 10)
    delay_ms(10)
    i -= 2
  end
end
