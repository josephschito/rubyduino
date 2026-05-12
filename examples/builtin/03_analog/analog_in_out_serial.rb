# AnalogInOutSerial
#
# Reads a pot on A0, scales to 0–255 PWM on pin 9, prints both values.
#
# https://docs.arduino.cc/built-in-examples/analog/AnalogInOutSerial/

analog_in_pin = ArduinoUNO::A0
analog_out_pin = 9

serial_begin(9600)

loop do
  sensor_value = analog_read(analog_in_pin)
  output_value = map_value(sensor_value, 0, 1023, 0, 255)
  analog_write(analog_out_pin, output_value)

  serial_print("sensor = ")
  serial_print(sensor_value)
  serial_print("\t output = ")
  serial_println(output_value)

  delay_ms(2)
end
