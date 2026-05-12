# Memsic2125
#
# Decodes pulse widths from a Memsic 2125 two-axis accelerometer on D2/D3
# into milli-g accelerations.
#
# https://docs.arduino.cc/built-in-examples/sensors/Memsic2125/

x_pin = 2
y_pin = 3

serial_begin(9600)
pin_mode(x_pin, ArduinoUNO::INPUT)
pin_mode(y_pin, ArduinoUNO::INPUT)

loop do
  pulse_x = pulse_in(x_pin, ArduinoUNO::HIGH)
  pulse_y = pulse_in(y_pin, ArduinoUNO::HIGH)

  acceleration_x = ((pulse_x / 10) - 500) * 8
  acceleration_y = ((pulse_y / 10) - 500) * 8

  serial_print(acceleration_x)
  serial_print("\t")
  serial_println(acceleration_y)

  delay_ms(100)
end
