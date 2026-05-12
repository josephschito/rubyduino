# Serial print (read the potentiometer)
#
# Reads the potentiometer on A5 every half a second and prints the
# value to the Serial Monitor. Useful for understanding what a sensor
# is doing without any LEDs.

POT_PIN  = ArduinoUNO::A5
DLY_TIME = 500

serial_begin(9600)

loop do
  pot_value = analog_read(POT_PIN)
  serial_print("The pot value is: ")
  serial_println(pot_value)
  delay_ms(DLY_TIME)
end
