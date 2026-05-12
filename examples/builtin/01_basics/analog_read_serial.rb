# AnalogReadSerial
#
# Reads an analog input on pin A0, prints the result to the Serial Monitor.
#
# https://docs.arduino.cc/built-in-examples/basics/AnalogReadSerial/

serial_begin(9600)

loop do
  sensor_value = analog_read(ArduinoUNO::A0)
  serial_println(sensor_value)
  delay_ms(1)
end
