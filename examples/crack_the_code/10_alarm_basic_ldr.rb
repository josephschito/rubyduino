# Alarm (LDR trigger)
#
# Like the basic alarm, but the trigger is the light sensor (LDR) on
# pin 4. Once armed, if the light level rises above THRESHOLD (someone
# opens the box and lets light in), the alarm triggers.

THRESHOLD  = 100
SENSOR_PIN = 4
FLASH_PIN  = 13
BUZZER_PIN = 3

pin_mode(SENSOR_PIN, ArduinoUNO::INPUT)
pin_mode(FLASH_PIN, ArduinoUNO::OUTPUT)
pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)
serial_begin(9600)

status = 0

loop do
  sensor = analog_read(SENSOR_PIN)
  serial_println(sensor)

  if status == 0
    delay_ms(3000)
    tone(BUZZER_PIN, 725, 40)
    delay_ms(200)
    tone(BUZZER_PIN, 725, 40)
    status = 1
  end

  if status == 1 && sensor > THRESHOLD
    delay_ms(2000)
    status = 2
  end

  if status == 2
    digital_write(FLASH_PIN, ArduinoUNO::HIGH)
    tone(BUZZER_PIN, 725, 1000)
    delay_ms(1000)
    tone(BUZZER_PIN, 330, 1000)
    delay_ms(1000)
  end
end
