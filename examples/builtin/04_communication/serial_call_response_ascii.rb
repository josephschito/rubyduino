# SerialCallResponseASCII
#
# Like SerialCallResponse but emits CSV ASCII text instead of raw bytes.
#
# https://docs.arduino.cc/built-in-examples/communication/SerialCallResponseASCII/

def establish_contact
  while serial_available <= 0
    serial_println("0,0,0")
    delay_ms(300)
  end
end

serial_begin(9600)
pin_mode(2, ArduinoUNO::INPUT)
establish_contact

loop do
  if serial_available > 0
    in_byte = serial_read
    first_sensor = analog_read(ArduinoUNO::A0)
    second_sensor = analog_read(ArduinoUNO::A1)
    third_sensor = map_value(digital_read(2), 0, 1, 0, 255)

    serial_print(first_sensor)
    serial_print(",")
    serial_print(second_sensor)
    serial_print(",")
    serial_println(third_sensor)
  end
end
