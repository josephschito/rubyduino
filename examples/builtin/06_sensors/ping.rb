# Ping
#
# Drives a Parallax PING))) ultrasonic rangefinder on D7, prints inches and cm.
#
# https://docs.arduino.cc/built-in-examples/sensors/Ping/

ping_pin = 7

def microseconds_to_inches(us)
  us / 74 / 2
end

def microseconds_to_centimeters(us)
  us / 29 / 2
end

serial_begin(9600)

loop do
  pin_mode(ping_pin, ArduinoUNO::OUTPUT)
  digital_write(ping_pin, ArduinoUNO::LOW)
  delay_us(2)
  digital_write(ping_pin, ArduinoUNO::HIGH)
  delay_us(5)
  digital_write(ping_pin, ArduinoUNO::LOW)

  pin_mode(ping_pin, ArduinoUNO::INPUT)
  duration = pulse_in(ping_pin, ArduinoUNO::HIGH)

  inches = microseconds_to_inches(duration)
  cm = microseconds_to_centimeters(duration)

  serial_print(inches)
  serial_print("in, ")
  serial_print(cm)
  serial_println("cm")

  delay_ms(100)
end
