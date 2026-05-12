# Stepper motor — 200 steps each way at 60 RPM
#
# Wiring: 4 coil drive lines on D8..D11 (e.g. ULN2003 to a 28BYJ-48
# motor; for a 28BYJ in half-step mode you'll want 2048 steps/rev).

stepper_begin(200, 8, 9, 10, 11)
stepper_set_speed(60)

loop do
  stepper_step(200)
  sleep_ms(500)
  stepper_step(-200)
  sleep_ms(500)
end
