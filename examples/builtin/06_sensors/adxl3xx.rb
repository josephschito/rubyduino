# ADXL3xx
#
# Reads an Analog Devices ADXL3xx accelerometer wired into A1–A5.
#
# https://docs.arduino.cc/built-in-examples/sensors/ADXL3xx/

ground_pin = 18
power_pin = 19
x_pin = ArduinoUNO::A3
y_pin = ArduinoUNO::A2
z_pin = ArduinoUNO::A1

serial_begin(9600)

pin_mode(ground_pin, ArduinoUNO::OUTPUT)
pin_mode(power_pin, ArduinoUNO::OUTPUT)
digital_write(ground_pin, ArduinoUNO::LOW)
digital_write(power_pin, ArduinoUNO::HIGH)

loop do
  serial_print(analog_read(x_pin))
  serial_print("\t")
  serial_print(analog_read(y_pin))
  serial_print("\t")
  serial_println(analog_read(z_pin))
  delay_ms(100)
end
