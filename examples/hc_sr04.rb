trig_pin = 9
echo_pin = 10
led_pin = 13

pin_mode(trig_pin, ArduinoUNO::OUTPUT)
pin_mode(echo_pin, ArduinoUNO::INPUT)
pin_mode(led_pin, ArduinoUNO::OUTPUT)

serial_begin(9600)

loop do
  digital_write(trig_pin, ArduinoUNO::LOW)
  delay_us(2)

  digital_write(trig_pin, ArduinoUNO::HIGH)
  delay_us(10)
  digital_write(trig_pin, ArduinoUNO::LOW)

  duration = pulse_in(echo_pin, ArduinoUNO::HIGH)
  distance = duration * 34 / 2000

  serial_print("Distance: ")
  serial_print(distance)
  serial_println(" cm")

  blink_delay = 700

  if distance < 10
    blink_delay = 100
  elsif distance < 30
    blink_delay = 300
  end

  digital_write(led_pin, ArduinoUNO::HIGH)
  delay_ms(blink_delay)

  digital_write(led_pin, ArduinoUNO::LOW)
  delay_ms(blink_delay)
end
