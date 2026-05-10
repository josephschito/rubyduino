# Alarm (LDR trigger, with reset)
#
# Same as the LDR alarm, but pressing the button on pin 7 while the
# alarm is sounding resets it back to the exit-delay state.

THRESHOLD  = 100
SENSOR_PIN = 4
RESET_PIN  = 7
FLASH_PIN  = 13
BUZZER_PIN = 3

pin_mode(SENSOR_PIN, ArduinoUNO::INPUT)
pin_mode(RESET_PIN, ArduinoUNO::INPUT)
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
    status = 2
  end

  if status == 2
    digital_write(FLASH_PIN, ArduinoUNO::HIGH)
    tone(BUZZER_PIN, 725, 500)
    reset_value = digital_read(RESET_PIN)
    if reset_value == ArduinoUNO::HIGH
      status = 0
    end
  end
end
