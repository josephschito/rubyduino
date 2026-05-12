# SerialCallResponse
#
# Sends 'A' until the host responds, then ships three sensor bytes per request.
#
# https://docs.arduino.cc/built-in-examples/communication/SerialCallResponse/

def establish_contact
  while serial_available <= 0
    serial_write(?A.ord)
    delay_ms(300)
  end
end

serial_begin(9600)
pin_mode(2, ArduinoUNO::INPUT)
establish_contact

loop do
  if serial_available > 0
    in_byte = serial_read
    first_sensor = analog_read(ArduinoUNO::A0) / 4
    delay_ms(10)
    second_sensor = analog_read(ArduinoUNO::A1) / 4
    third_sensor = map_value(digital_read(2), 0, 1, 0, 255)

    serial_write(first_sensor)
    serial_write(second_sensor)
    serial_write(third_sensor)
  end
end
