# Fade
#
# Fades an LED on pin 9 using analog_write (PWM).
#
# https://docs.arduino.cc/built-in-examples/basics/Fade/

led = 9
brightness = 0
fade_amount = 5

pin_mode(led, ArduinoUNO::OUTPUT)

loop do
  analog_write(led, brightness)

  brightness = brightness + fade_amount
  if brightness <= 0 || brightness >= 255
    fade_amount = -fade_amount
  end

  delay_ms(30)
end
