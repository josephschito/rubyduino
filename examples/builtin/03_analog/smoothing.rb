# Smoothing
#
# Keeps a rolling average of the last 10 readings from A0 and prints it.
#
# https://docs.arduino.cc/built-in-examples/analog/Smoothing/

num_readings = 10
readings = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
read_index = 0
total = 0
input_pin = ArduinoUNO::A0

serial_begin(9600)

loop do
  total = total - readings[read_index]
  readings[read_index] = analog_read(input_pin)
  total = total + readings[read_index]

  read_index = read_index + 1
  read_index = 0 if read_index >= num_readings

  average = total / num_readings
  serial_println(average)
  delay_ms(1)
end
