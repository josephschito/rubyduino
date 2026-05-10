# Buzzer (single beep)
#
# Plays a 600 Hz tone on the buzzer (pin 2) for 30 ms, then pauses
# 150 ms before doing it again. Sounds like a steady tick.

BUZZER_PIN = 2

pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)

loop do
  tone(BUZZER_PIN, 600, 30)
  delay_ms(150)
end
