# Alarm (full state machine)
#
# A fuller intruder alarm with:
#   - five states (standby, exit delay, armed, entry delay, triggered)
#   - status LEDs for each state (pins 8..12) plus a "trigger ready"
#     LED on pin 13
#   - potentiometer (A5) sets the sensitivity threshold
#   - LDR (pin 4) is the actual trip sensor
#   - button (pin 7) cycles modes / resets
#
# Read the Serial Monitor at 9600 baud to see the current state.

POT_PIN          = 5
LDR_PIN          = 4
BUTTON_PIN       = 7
BUZZER_PIN       = 3
STANDBY_LED_PIN  = 8
EXIT_LED_PIN     = 9
ARMED_LED_PIN    = 10
ENTRY_LED_PIN    = 11
TRIGGERED_LED_PIN = 12
SET_LED_PIN      = 13

pin_mode(POT_PIN, ArduinoUNO::INPUT)
pin_mode(LDR_PIN, ArduinoUNO::INPUT)
pin_mode(BUTTON_PIN, ArduinoUNO::INPUT)
pin_mode(BUZZER_PIN, ArduinoUNO::OUTPUT)
pin_mode(STANDBY_LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(EXIT_LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(ARMED_LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(ENTRY_LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(TRIGGERED_LED_PIN, ArduinoUNO::OUTPUT)
pin_mode(SET_LED_PIN, ArduinoUNO::OUTPUT)
serial_begin(9600)

status     = 0
pot_value  = 0
ldr_value  = 0

loop do
  if status == 0
    digital_write(EXIT_LED_PIN, ArduinoUNO::LOW)
    digital_write(ARMED_LED_PIN, ArduinoUNO::LOW)
    digital_write(ENTRY_LED_PIN, ArduinoUNO::LOW)
    digital_write(TRIGGERED_LED_PIN, ArduinoUNO::LOW)
    digital_write(STANDBY_LED_PIN, ArduinoUNO::HIGH)

    pot_value = analog_read(POT_PIN)
    ldr_value = analog_read(LDR_PIN)
    serial_print("STANDBY   Threshold level: ")
    serial_print(pot_value)
    serial_print("    Light level: ")
    serial_println(ldr_value)

    if pot_value < (50 + (ldr_value / 2))
      digital_write(SET_LED_PIN, ArduinoUNO::HIGH)
    else
      digital_write(SET_LED_PIN, ArduinoUNO::LOW)
    end

    button_value = digital_read(BUTTON_PIN)
    if button_value == ArduinoUNO::HIGH
      status = 1
      delay_ms(400)
    end
  end

  if status == 1
    digital_write(STANDBY_LED_PIN, ArduinoUNO::LOW)
    digital_write(ARMED_LED_PIN, ArduinoUNO::LOW)
    digital_write(ENTRY_LED_PIN, ArduinoUNO::LOW)
    digital_write(TRIGGERED_LED_PIN, ArduinoUNO::LOW)
    digital_write(SET_LED_PIN, ArduinoUNO::LOW)
    digital_write(EXIT_LED_PIN, ArduinoUNO::HIGH)
    serial_println("EXIT DELAY")
    delay_ms(3000)
    tone(BUZZER_PIN, 600, 20)
    delay_ms(200)
    tone(BUZZER_PIN, 600, 20)
    status = 2
  end

  if status == 2
    digital_write(STANDBY_LED_PIN, ArduinoUNO::LOW)
    digital_write(EXIT_LED_PIN, ArduinoUNO::LOW)
    digital_write(ENTRY_LED_PIN, ArduinoUNO::LOW)
    digital_write(TRIGGERED_LED_PIN, ArduinoUNO::LOW)
    digital_write(SET_LED_PIN, ArduinoUNO::LOW)
    digital_write(ARMED_LED_PIN, ArduinoUNO::HIGH)

    ldr_value = analog_read(LDR_PIN)
    serial_print("ARMED  Threshold level: ")
    serial_print(pot_value)
    serial_print("    Light level: ")
    serial_println(ldr_value)
    if pot_value < ldr_value
      status = 3
    end
  end

  if status == 3
    digital_write(STANDBY_LED_PIN, ArduinoUNO::LOW)
    digital_write(EXIT_LED_PIN, ArduinoUNO::LOW)
    digital_write(ARMED_LED_PIN, ArduinoUNO::LOW)
    digital_write(TRIGGERED_LED_PIN, ArduinoUNO::LOW)
    digital_write(SET_LED_PIN, ArduinoUNO::LOW)
    digital_write(ENTRY_LED_PIN, ArduinoUNO::HIGH)
    serial_println("ENTRY DELAY")

    count = 0
    reset_pressed = false
    while count <= 300 && !reset_pressed
      button_value = digital_read(BUTTON_PIN)
      if button_value == ArduinoUNO::HIGH
        delay_ms(200)
        status = 0
        reset_pressed = true
      else
        delay_ms(10)
      end
      count += 1
    end
    if !reset_pressed
      status = 4
    end
  end

  if status == 4
    digital_write(STANDBY_LED_PIN, ArduinoUNO::LOW)
    digital_write(EXIT_LED_PIN, ArduinoUNO::LOW)
    digital_write(ARMED_LED_PIN, ArduinoUNO::LOW)
    digital_write(ENTRY_LED_PIN, ArduinoUNO::LOW)
    digital_write(SET_LED_PIN, ArduinoUNO::LOW)
    digital_write(TRIGGERED_LED_PIN, ArduinoUNO::HIGH)
    serial_println("TRIGGERED")
    tone(BUZZER_PIN, 600, 50)
    button_value = digital_read(BUTTON_PIN)
    if button_value == ArduinoUNO::HIGH
      delay_ms(200)
      status = 0
    end
  end
end
