# Blink
#
# Turns an LED on for one second, then off for one second, repeatedly.
#
# https://docs.arduino.cc/built-in-examples/basics/Blink/

pin_mode(ArduinoUNO::LED_BUILTIN, ArduinoUNO::OUTPUT)

loop do
  digital_write(ArduinoUNO::LED_BUILTIN, ArduinoUNO::HIGH)
  delay_ms(1000)
  digital_write(ArduinoUNO::LED_BUILTIN, ArduinoUNO::LOW)
  delay_ms(1000)
end
