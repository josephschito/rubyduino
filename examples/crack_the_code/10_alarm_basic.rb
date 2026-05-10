# Alarm (basic switch)
#
# A simple intruder alarm. Pin 7 is the trip switch (e.g. copper tape
# on the lid). After arming, opening the lid (sensor reads 0) triggers
# the alarm: the on-board LED lights and the buzzer plays a two-tone
# siren forever.

SENSOR_PIN = 7
FLASH_PIN  = 13
BUZZER_PIN = 3

pin_mode(SENSOR_PIN, ArduinoUNO::INPUT)
pin_mode(FLASH_PIN, ArduinoUNO::OUTPUT)
pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)

status = 0   # 0 = exit delay, 1 = armed, 2 = triggered
sensor = 0

loop do
  if status == 0
    delay_ms(3000)        # 3 seconds to close the box
    tone(BUZZER_PIN, 725, 40)
    delay_ms(200)
    tone(BUZZER_PIN, 725, 40)
    status = 1
  end

  if status == 1
    sensor = digital_read(SENSOR_PIN)
  end

  if sensor == 0
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
