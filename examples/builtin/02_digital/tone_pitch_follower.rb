# tonePitchFollower
#
# Plays a pitch on pin 9 that tracks a photoresistor on A0.
#
# https://docs.arduino.cc/built-in-examples/digital/tonePitchFollower/

serial_begin(9600)

loop do
  sensor_reading = analog_read(ArduinoUNO::A0)
  serial_println(sensor_reading)

  this_pitch = map_value(sensor_reading, 400, 1000, 120, 1500)
  tone(9, this_pitch, 10)
  delay_ms(1)
end
