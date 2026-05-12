# DHT22 to Serial
#
# Polls a DHT22 sensor on D7 every 2 seconds and prints temp/humidity.

DHT_PIN = 7

serial_begin(9600)

loop do
  if dht_read?(DHT_PIN, DHT22)
    t = dht_temperature_x10
    h = dht_humidity_x10
    serial_print("temp=")
    serial_print(t / 10)
    serial_print(".")
    serial_print(t % 10)
    serial_print("C  humid=")
    serial_print(h / 10)
    serial_print(".")
    serial_print(h % 10)
    serial_println("%")
  else
    serial_println("dht read failed")
  end
  sleep_ms(2000)
end
