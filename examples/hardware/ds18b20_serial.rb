# DS18B20 1-Wire temperature to Serial
#
# Reads a single DS18B20 on D4 once per second.
# Wire DQ to D4 with a 4.7k pull-up to +5V; VDD to +5V or ground (parasite).

DS_PIN = 4

serial_begin(9600)

loop do
  if ds18b20_request_temperature(DS_PIN) == 1
    sleep_ms(750) # 12-bit conversion time
    t = ds18b20_read_temperature_x10(DS_PIN)
    serial_print("temp=")
    serial_print(t / 10)
    serial_print(".")
    serial_print(t % 10)
    serial_println("C")
  else
    serial_println("no DS18B20 detected")
  end
  sleep_ms(1000)
end
