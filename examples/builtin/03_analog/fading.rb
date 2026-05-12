# Fading
#
# Fades an LED up and down on pin 9 using analog_write.
#
# https://docs.arduino.cc/built-in-examples/analog/Fading/

led_pin = 9

loop do
  fade_value = 0
  while fade_value <= 255
    analog_write(led_pin, fade_value)
    delay_ms(30)
    fade_value += 5
  end

  fade_value = 255
  while fade_value >= 0
    analog_write(led_pin, fade_value)
    delay_ms(30)
    fade_value -= 5
  end
end
