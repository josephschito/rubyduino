# Fade
#
# Smoothly fades the LED on pin 11 (a PWM pin, marked with a ~ on
# the board) up and down forever. Brightness goes 0 → 255 → 0 in
# steps of 5, with a 30 ms pause between steps.

LED = 11

pin_mode(LED, ArduinoUNO::OUTPUT)

brightness  = 0
fade_amount = 5

loop do
  analog_write(LED, brightness)
  brightness += fade_amount
  if brightness <= 0 || brightness >= 255
    fade_amount = -fade_amount
  end
  delay_ms(30)
end
