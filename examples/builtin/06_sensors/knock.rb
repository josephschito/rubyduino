# Knock
#
# Toggles LED 13 and prints "Knock!" when a piezo sensor on A0 spikes.
#
# https://docs.arduino.cc/built-in-examples/sensors/Knock/

led_pin = 13
knock_sensor = ArduinoUNO::A0
threshold = 100

led_state = ArduinoUNO::LOW

pin_mode(led_pin, ArduinoUNO::OUTPUT)
serial_begin(9600)

loop do
  sensor_reading = analog_read(knock_sensor)

  if sensor_reading >= threshold
    led_state = led_state == ArduinoUNO::HIGH ? ArduinoUNO::LOW : ArduinoUNO::HIGH
    digital_write(led_pin, led_state)
    serial_println("Knock!")
    delay_ms(100)
  end
end
