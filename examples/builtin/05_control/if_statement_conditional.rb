# IfStatementConditional
#
# Lights LED 13 only when A0 reading exceeds a threshold; always logs the value.
#
# https://docs.arduino.cc/built-in-examples/control-structures/ifStatementConditional/

analog_pin = ArduinoUNO::A0
led_pin = 13
threshold = 400

pin_mode(led_pin, ArduinoUNO::OUTPUT)
serial_begin(9600)

loop do
  analog_value = analog_read(analog_pin)

  if analog_value > threshold
    digital_write(led_pin, ArduinoUNO::HIGH)
  else
    digital_write(led_pin, ArduinoUNO::LOW)
  end

  serial_println(analog_value)
  delay_ms(1)
end
