# ReadAnalogVoltage
#
# Reads an analog input on pin A0, converts it to voltage, and prints to Serial.
#
# https://docs.arduino.cc/built-in-examples/basics/ReadAnalogVoltage/

serial_begin(9600)

loop do
  sensor_value = analog_read(ArduinoUNO::A0)
  voltage = sensor_value * (5.0 / 1023.0)
  serial_println(voltage, 2)
end
