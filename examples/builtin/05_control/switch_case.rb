# switchCase
#
# Buckets a photoresistor reading on A0 into 4 ranges with case/when.
#
# https://docs.arduino.cc/built-in-examples/control-structures/SwitchCase/

sensor_min = 0
sensor_max = 600

serial_begin(9600)

loop do
  sensor_reading = analog_read(ArduinoUNO::A0)
  range = map_value(sensor_reading, sensor_min, sensor_max, 0, 3)

  case range
  when 0
    serial_println("dark")
  when 1
    serial_println("dim")
  when 2
    serial_println("medium")
  when 3
    serial_println("bright")
  end

  delay_ms(1)
end
