module ArduinoUNO
  LOW = 0
  HIGH = 1

  INPUT = 0
  OUTPUT = 1
  INPUT_PULLUP = 2

  A0 = 14
  A1 = 15
  A2 = 16
  A3 = 17
  A4 = 18
  A5 = 19

  LED_BUILTIN = 13
  LSBFIRST = 0
  MSBFIRST = 1

  INT_LOW = 0
  INT_CHANGE = 1
  INT_FALLING = 2
  INT_RISING = 3

  AREF_EXTERNAL = 0
  AREF_DEFAULT = 1
  AREF_INTERNAL = 3

  BIN = 2
  OCT = 8
  DEC = 10
  HEX = 16

  SPI_MODE0 = 0
  SPI_MODE1 = 1
  SPI_MODE2 = 2
  SPI_MODE3 = 3
  SPI_CLOCK_DIV4 = 0
  SPI_CLOCK_DIV16 = 1
  SPI_CLOCK_DIV64 = 2
  SPI_CLOCK_DIV128 = 3
  SPI_CLOCK_DIV2 = 4
  SPI_CLOCK_DIV8 = 5
  SPI_CLOCK_DIV32 = 6
end

# Ruby-style alias module. ArduinoUNO is the original Arduino spelling and
# stays the canonical home for the FFI bindings. ArduinoUno mirrors every
# constant so sketches can use the more Ruby-idiomatic capitalization.
module ArduinoUno
  LOW = 0
  HIGH = 1

  INPUT = 0
  OUTPUT = 1
  INPUT_PULLUP = 2

  A0 = 14
  A1 = 15
  A2 = 16
  A3 = 17
  A4 = 18
  A5 = 19

  LED_BUILTIN = 13
  LSBFIRST = 0
  MSBFIRST = 1

  INT_LOW = 0
  INT_CHANGE = 1
  INT_FALLING = 2
  INT_RISING = 3

  AREF_EXTERNAL = 0
  AREF_DEFAULT = 1
  AREF_INTERNAL = 3

  BIN = 2
  OCT = 8
  DEC = 10
  HEX = 16

  SPI_MODE0 = 0
  SPI_MODE1 = 1
  SPI_MODE2 = 2
  SPI_MODE3 = 3
  SPI_CLOCK_DIV4 = 0
  SPI_CLOCK_DIV16 = 1
  SPI_CLOCK_DIV64 = 2
  SPI_CLOCK_DIV128 = 3
  SPI_CLOCK_DIV2 = 4
  SPI_CLOCK_DIV8 = 5
  SPI_CLOCK_DIV32 = 6
end

module ArduinoUNO
  ffi_func :pin_mode, [:uint8, :uint8], :int
  ffi_func :digital_write, [:uint8, :uint8], :int
  ffi_func :digital_read, [:uint8], :int
  ffi_func :analog_read, [:uint8], :int
  ffi_func :analog_write, [:uint8, :uint8], :int
  ffi_func :delay_ms, [:uint32], :void
  ffi_func :delay_us, [:uint32], :void
  ffi_func :millis, [], :uint32
  ffi_func :micros, [], :uint32
  ffi_func :pulse_in, [:uint8, :uint8], :uint32
  ffi_func :pulse_in_timeout, [:uint8, :uint8, :uint32], :uint32
  ffi_func :serial_begin, [:uint32], :void
  ffi_func :serial_available, [], :int
  ffi_func :serial_read, [], :int
  ffi_func :serial_write, [:uint8], :void
  ffi_func :serial_print_str, [:str], :void
  ffi_func :serial_print_int, [:int], :void
  ffi_func :serial_println_str, [:str], :void
  ffi_func :serial_println_int, [:int], :void
  ffi_func :shift_in, [:uint8, :uint8, :uint8], :uint8
  ffi_func :shift_out, [:uint8, :uint8, :uint8, :uint8], :void
  ffi_func :interrupts, [], :void
  ffi_func :no_interrupts, [], :void
  ffi_func :bit, [:uint8], :uint32
  ffi_func :bit_read, [:uint32, :uint8], :uint8
  ffi_func :bit_write, [:uint32, :uint8, :uint8], :uint32
  ffi_func :bit_set, [:uint32, :uint8], :uint32
  ffi_func :bit_clear, [:uint32, :uint8], :uint32
  ffi_func :high_byte, [:uint16], :uint8
  ffi_func :low_byte, [:uint16], :uint8
  ffi_func :map_value, [:int32, :int32, :int32, :int32, :int32], :int32
  ffi_func :constrain, [:int32, :int32, :int32], :int32
  ffi_func :sq, [:int32], :int32
  ffi_func :is_alpha, [:int], :int
  ffi_func :is_digit, [:int], :int
  ffi_func :is_alpha_numeric, [:int], :int
  ffi_func :is_space, [:int], :int
  ffi_func :is_whitespace, [:int], :int
  ffi_func :is_upper_case, [:int], :int
  ffi_func :is_lower_case, [:int], :int
  ffi_func :is_ascii, [:int], :int
  ffi_func :is_control, [:int], :int
  ffi_func :is_printable, [:int], :int
  ffi_func :is_punct, [:int], :int
  ffi_func :is_hexadecimal_digit, [:int], :int
  ffi_func :is_graph, [:int], :int
  ffi_func :random_seed, [:uint32], :void
  ffi_func :random_range, [:int32, :int32], :int32
  ffi_func :random_max, [:int32], :int32
  ffi_func :tone_for, [:uint8, :uint16, :uint32], :void
  ffi_func :no_tone, [:uint8], :void
  ffi_func :attach_interrupt, [:uint8, :uint8], :void
  ffi_func :detach_interrupt, [:uint8], :void
  ffi_func :interrupt_fired, [:uint8], :uint8
  ffi_func :digital_pin_to_interrupt, [:uint8], :int8
  ffi_func :analog_reference, [:uint8], :void
  ffi_func :serial_end, [], :void
  ffi_func :serial_flush, [], :void
  ffi_func :serial_peek, [], :int
  ffi_func :serial_available_for_write, [], :int
  ffi_func :serial_set_timeout, [:uint32], :void
  ffi_func :serial_get_timeout, [], :uint32
  ffi_func :serial_read_byte_timeout, [], :int
  ffi_func :serial_parse_int, [], :int32
  ffi_func :serial_parse_float, [], :double
  ffi_func :serial_find, [:str], :uint8
  ffi_func :serial_find_until, [:str, :str], :uint8
  ffi_func :serial_print_hex, [:uint32], :void
  ffi_func :serial_print_bin, [:uint32], :void
  ffi_func :serial_print_oct, [:uint32], :void
  ffi_func :serial_print_float, [:double, :uint8], :void
  ffi_func :serial_println_hex, [:uint32], :void
  ffi_func :serial_println_bin, [:uint32], :void
  ffi_func :serial_println_oct, [:uint32], :void
  ffi_func :serial_println_float, [:double, :uint8], :void
  ffi_func :eeprom_read, [:uint16], :uint8
  ffi_func :eeprom_write, [:uint16, :uint8], :void
  ffi_func :eeprom_update, [:uint16, :uint8], :void
  ffi_func :eeprom_length, [], :uint16
  ffi_func :eeprom_read_int, [:uint16], :int32
  ffi_func :eeprom_write_int, [:uint16, :int32], :void
  ffi_func :spi_begin, [], :void
  ffi_func :spi_end, [], :void
  ffi_func :spi_set_bit_order, [:uint8], :void
  ffi_func :spi_set_clock_divider, [:uint8], :void
  ffi_func :spi_set_data_mode, [:uint8], :void
  ffi_func :spi_transfer, [:uint8], :uint8
  ffi_func :spi_transfer16, [:uint16], :uint16
  ffi_func :wire_begin, [], :void
  ffi_func :wire_end, [], :void
  ffi_func :wire_set_clock, [:uint32], :void
  ffi_func :wire_begin_transmission, [:uint8], :void
  ffi_func :wire_write, [:uint8], :uint8
  ffi_func :wire_end_transmission, [:uint8], :uint8
  ffi_func :wire_request_from, [:uint8, :uint8, :uint8], :uint8
  ffi_func :wire_available, [], :int
  ffi_func :wire_read, [], :int
  ffi_func :servo_attach, [:uint8], :void
  ffi_func :servo_detach, [], :void
  ffi_func :servo_write, [:uint8], :void
  ffi_func :servo_write_microseconds, [:uint16], :void
  ffi_func :servo_read, [], :uint8
  ffi_func :servo_read_microseconds, [], :uint16
  ffi_func :servo_attached, [], :uint8
  ffi_func :arduino_yield, [], :void
  ffi_func :neopixel_begin, [:uint8, :uint16], :void
  ffi_func :neopixel_set_pixel, [:uint16, :uint8, :uint8, :uint8], :void
  ffi_func :neopixel_clear, [], :void
  ffi_func :neopixel_show, [], :void
  ffi_func :dht_read, [:uint8, :uint8], :int8
  ffi_func :dht_temperature_x10, [], :int16
  ffi_func :dht_humidity_x10, [], :int16
  ffi_func :onewire_reset, [:uint8], :uint8
  ffi_func :onewire_write_byte, [:uint8, :uint8], :void
  ffi_func :onewire_read_byte, [:uint8], :uint8
  ffi_func :ds18b20_request_temperature, [:uint8], :uint8
  ffi_func :ds18b20_read_temperature_x10, [:uint8], :int16
  ffi_func :lcd_begin, [:uint8, :uint8, :uint8, :uint8, :uint8, :uint8, :uint8, :uint8], :void
  ffi_func :lcd_clear, [], :void
  ffi_func :lcd_home, [], :void
  ffi_func :lcd_set_cursor, [:uint8, :uint8], :void
  ffi_func :lcd_write_char, [:uint8], :void
  ffi_func :lcd_print_str, [:str], :void
  ffi_func :lcd_print_int, [:int32], :void
  ffi_func :stepper_begin, [:uint16, :uint8, :uint8, :uint8, :uint8], :void
  ffi_func :stepper_set_speed, [:uint16], :void
  ffi_func :stepper_step, [:int16], :void
  ffi_func :soft_serial_begin, [:uint8, :uint8, :uint32], :void
  ffi_func :soft_serial_write, [:uint8], :void
  ffi_func :soft_serial_print_str, [:str], :void
  ffi_func :soft_serial_read, [], :int
  ffi_func :ir_receive, [:uint8, :uint32], :int8
  ffi_func :ir_command, [], :uint32
end

def pin_mode(pin, mode)
  ArduinoUNO.pin_mode(pin, mode)
end

def digital_write(pin, value)
  ArduinoUNO.digital_write(pin, value)
end

def digital_read(pin)
  ArduinoUNO.digital_read(pin)
end

def analog_read(pin)
  ArduinoUNO.analog_read(pin)
end

def analog_write(pin, value)
  ArduinoUNO.analog_write(pin, value)
end

def delay_ms(ms)
  ArduinoUNO.delay_ms(ms)
end

def delay_us(us)
  ArduinoUNO.delay_us(us)
end

def sleep_ms(ms)
  ArduinoUNO.delay_ms(ms)
end

def sleep_us(us)
  ArduinoUNO.delay_us(us)
end

def millis
  ArduinoUNO.millis
end

def micros
  ArduinoUNO.micros
end

def pulse_in(pin, value)
  ArduinoUNO.pulse_in(pin, value)
end

def pulse_in_timeout(pin, value, timeout_us)
  ArduinoUNO.pulse_in_timeout(pin, value, timeout_us)
end

def serial_begin(baud)
  ArduinoUNO.serial_begin(baud)
end

def serial_available
  ArduinoUNO.serial_available
end

def serial_read
  ArduinoUNO.serial_read
end

def serial_write(value)
  ArduinoUNO.serial_write(value)
end

def shift_in(data_pin, clock_pin, bit_order)
  ArduinoUNO.shift_in(data_pin, clock_pin, bit_order)
end

def shift_out(data_pin, clock_pin, bit_order, value)
  ArduinoUNO.shift_out(data_pin, clock_pin, bit_order, value)
end

def interrupts
  ArduinoUNO.interrupts
end

def no_interrupts
  ArduinoUNO.no_interrupts
end

def without_interrupts
  ArduinoUNO.no_interrupts
  yield
  ArduinoUNO.interrupts
end

def bit(n)
  ArduinoUNO.bit(n)
end

def bit_read(value, n)
  ArduinoUNO.bit_read(value, n)
end

def bit_write(value, n, bitvalue)
  ArduinoUNO.bit_write(value, n, bitvalue)
end

def bit_set(value, n)
  ArduinoUNO.bit_set(value, n)
end

def bit_clear(value, n)
  ArduinoUNO.bit_clear(value, n)
end

def high_byte(value)
  ArduinoUNO.high_byte(value)
end

def low_byte(value)
  ArduinoUNO.low_byte(value)
end

def map_value(value, from_low, from_high, to_low, to_high)
  ArduinoUNO.map_value(value, from_low, from_high, to_low, to_high)
end

def constrain(value, low, high)
  ArduinoUNO.constrain(value, low, high)
end

def sq(value)
  ArduinoUNO.sq(value)
end

def clamp(value, low, high)
  ArduinoUNO.constrain(value, low, high)
end

def square(value)
  ArduinoUNO.sq(value)
end

def is_alpha(c)
  ArduinoUNO.is_alpha(c)
end

def is_digit(c)
  ArduinoUNO.is_digit(c)
end

def is_alpha_numeric(c)
  ArduinoUNO.is_alpha_numeric(c)
end

def is_space(c)
  ArduinoUNO.is_space(c)
end

def is_whitespace(c)
  ArduinoUNO.is_whitespace(c)
end

def is_upper_case(c)
  ArduinoUNO.is_upper_case(c)
end

def is_lower_case(c)
  ArduinoUNO.is_lower_case(c)
end

def is_ascii(c)
  ArduinoUNO.is_ascii(c)
end

def is_control(c)
  ArduinoUNO.is_control(c)
end

def is_printable(c)
  ArduinoUNO.is_printable(c)
end

def is_punct(c)
  ArduinoUNO.is_punct(c)
end

def is_hexadecimal_digit(c)
  ArduinoUNO.is_hexadecimal_digit(c)
end

def is_graph(c)
  ArduinoUNO.is_graph(c)
end

def is_alpha?(c)
  ArduinoUNO.is_alpha(c) == 1
end

def is_digit?(c)
  ArduinoUNO.is_digit(c) == 1
end

def is_alpha_numeric?(c)
  ArduinoUNO.is_alpha_numeric(c) == 1
end

def is_space?(c)
  ArduinoUNO.is_space(c) == 1
end

def is_whitespace?(c)
  ArduinoUNO.is_whitespace(c) == 1
end

def is_upper_case?(c)
  ArduinoUNO.is_upper_case(c) == 1
end

def is_lower_case?(c)
  ArduinoUNO.is_lower_case(c) == 1
end

def is_ascii?(c)
  ArduinoUNO.is_ascii(c) == 1
end

def is_control?(c)
  ArduinoUNO.is_control(c) == 1
end

def is_printable?(c)
  ArduinoUNO.is_printable(c) == 1
end

def is_punct?(c)
  ArduinoUNO.is_punct(c) == 1
end

def is_hexadecimal_digit?(c)
  ArduinoUNO.is_hexadecimal_digit(c) == 1
end

def is_graph?(c)
  ArduinoUNO.is_graph(c) == 1
end

# Ruby-idiomatic predicate aliases (without the is_ prefix). The Arduino-named
# versions above are kept as porting aliases.
def alpha?(c)
  ArduinoUNO.is_alpha(c) == 1
end

def digit?(c)
  ArduinoUNO.is_digit(c) == 1
end

def alphanumeric?(c)
  ArduinoUNO.is_alpha_numeric(c) == 1
end

def space?(c)
  ArduinoUNO.is_space(c) == 1
end

def whitespace?(c)
  ArduinoUNO.is_whitespace(c) == 1
end

def uppercase?(c)
  ArduinoUNO.is_upper_case(c) == 1
end

def lowercase?(c)
  ArduinoUNO.is_lower_case(c) == 1
end

def ascii?(c)
  ArduinoUNO.is_ascii(c) == 1
end

def control?(c)
  ArduinoUNO.is_control(c) == 1
end

def printable?(c)
  ArduinoUNO.is_printable(c) == 1
end

def punctuation?(c)
  ArduinoUNO.is_punct(c) == 1
end

def hex_digit?(c)
  ArduinoUNO.is_hexadecimal_digit(c) == 1
end

def graph?(c)
  ArduinoUNO.is_graph(c) == 1
end

def random_seed(seed)
  ArduinoUNO.random_seed(seed)
end

def srand(seed)
  ArduinoUNO.random_seed(seed)
end

def random_range(low, high)
  ArduinoUNO.random_range(low, high)
end

def random_max(high)
  ArduinoUNO.random_max(high)
end

def tone(pin, frequency, duration_ms = 0)
  ArduinoUNO.tone_for(pin, frequency, duration_ms)
end

def no_tone(pin)
  ArduinoUNO.no_tone(pin)
end

def stop_tone(pin)
  ArduinoUNO.no_tone(pin)
end

def pulse_in_long(pin, value, timeout_us = 1_000_000)
  ArduinoUNO.pulse_in_timeout(pin, value, timeout_us)
end

def attach_interrupt(interrupt_num, mode)
  ArduinoUNO.attach_interrupt(interrupt_num, mode)
end

def detach_interrupt(interrupt_num)
  ArduinoUNO.detach_interrupt(interrupt_num)
end

def interrupt_fired(interrupt_num)
  ArduinoUNO.interrupt_fired(interrupt_num)
end

def interrupt_fired?(interrupt_num)
  ArduinoUNO.interrupt_fired(interrupt_num) == 1
end

def digital_pin_to_interrupt(pin)
  ArduinoUNO.digital_pin_to_interrupt(pin)
end

def analog_reference(type)
  ArduinoUNO.analog_reference(type)
end

def serial_end
  ArduinoUNO.serial_end
end

def serial_flush
  ArduinoUNO.serial_flush
end

def serial_peek
  ArduinoUNO.serial_peek
end

def serial_available_for_write
  ArduinoUNO.serial_available_for_write
end

def serial_set_timeout(timeout_ms)
  ArduinoUNO.serial_set_timeout(timeout_ms)
end

def serial_get_timeout
  ArduinoUNO.serial_get_timeout
end

def serial_read_byte_timeout
  ArduinoUNO.serial_read_byte_timeout
end

def serial_parse_int
  ArduinoUNO.serial_parse_int
end

def serial_parse_float
  ArduinoUNO.serial_parse_float
end

def serial_find(target)
  ArduinoUNO.serial_find(target)
end

def serial_find?(target)
  ArduinoUNO.serial_find(target) == 1
end

def serial_find_until(target, terminator)
  ArduinoUNO.serial_find_until(target, terminator)
end

def serial_find_until?(target, terminator)
  ArduinoUNO.serial_find_until(target, terminator) == 1
end

def serial_print_hex(value)
  ArduinoUNO.serial_print_hex(value)
end

def serial_print_bin(value)
  ArduinoUNO.serial_print_bin(value)
end

def serial_print_oct(value)
  ArduinoUNO.serial_print_oct(value)
end

def serial_print_float(value, decimals = 2)
  ArduinoUNO.serial_print_float(value, decimals)
end

def serial_println_hex(value)
  ArduinoUNO.serial_println_hex(value)
end

def serial_println_bin(value)
  ArduinoUNO.serial_println_bin(value)
end

def serial_println_oct(value)
  ArduinoUNO.serial_println_oct(value)
end

def serial_println_float(value, decimals = 2)
  ArduinoUNO.serial_println_float(value, decimals)
end

def eeprom_read(addr)
  ArduinoUNO.eeprom_read(addr)
end

def eeprom_write(addr, value)
  ArduinoUNO.eeprom_write(addr, value)
end

def eeprom_update(addr, value)
  ArduinoUNO.eeprom_update(addr, value)
end

def eeprom_length
  ArduinoUNO.eeprom_length
end

def eeprom_read_int(addr)
  ArduinoUNO.eeprom_read_int(addr)
end

def eeprom_write_int(addr, value)
  ArduinoUNO.eeprom_write_int(addr, value)
end

def spi_begin
  ArduinoUNO.spi_begin
end

def spi_end
  ArduinoUNO.spi_end
end

def spi_set_bit_order(order)
  ArduinoUNO.spi_set_bit_order(order)
end

def spi_set_clock_divider(div)
  ArduinoUNO.spi_set_clock_divider(div)
end

def spi_set_data_mode(mode)
  ArduinoUNO.spi_set_data_mode(mode)
end

def spi_transfer(byte)
  ArduinoUNO.spi_transfer(byte)
end

def spi_transfer16(word)
  ArduinoUNO.spi_transfer16(word)
end

def wire_begin
  ArduinoUNO.wire_begin
end

def wire_end
  ArduinoUNO.wire_end
end

def wire_set_clock(speed_hz)
  ArduinoUNO.wire_set_clock(speed_hz)
end

def wire_begin_transmission(addr)
  ArduinoUNO.wire_begin_transmission(addr)
end

def wire_write(byte)
  ArduinoUNO.wire_write(byte)
end

def wire_end_transmission(stop = 1)
  ArduinoUNO.wire_end_transmission(stop)
end

def wire_request_from(addr, count, stop = 1)
  ArduinoUNO.wire_request_from(addr, count, stop)
end

def wire_available
  ArduinoUNO.wire_available
end

def wire_read
  ArduinoUNO.wire_read
end

def servo_attach(pin)
  ArduinoUNO.servo_attach(pin)
end

def servo_detach
  ArduinoUNO.servo_detach
end

def servo_write(angle)
  ArduinoUNO.servo_write(angle)
end

def servo_write_microseconds(us)
  ArduinoUNO.servo_write_microseconds(us)
end

def servo_read
  ArduinoUNO.servo_read
end

def servo_read_microseconds
  ArduinoUNO.servo_read_microseconds
end

def servo_attached
  ArduinoUNO.servo_attached
end

def servo_attached?
  ArduinoUNO.servo_attached == 1
end

def arduino_yield
  ArduinoUNO.arduino_yield
end

def neopixel_begin(pin, num_pixels)
  ArduinoUNO.neopixel_begin(pin, num_pixels)
end

def neopixel_set_pixel(index, r, g, b)
  ArduinoUNO.neopixel_set_pixel(index, r, g, b)
end

def neopixel_clear
  ArduinoUNO.neopixel_clear
end

def neopixel_show
  ArduinoUNO.neopixel_show
end

# DHT type constants. The DHT22 is also known as AM2302/RHT03.
DHT11 = 11
DHT22 = 22

def dht_read(pin, type = DHT22)
  ArduinoUNO.dht_read(pin, type)
end

def dht_read?(pin, type = DHT22)
  ArduinoUNO.dht_read(pin, type) == 0
end

def dht_temperature_x10
  ArduinoUNO.dht_temperature_x10
end

def dht_humidity_x10
  ArduinoUNO.dht_humidity_x10
end

def onewire_reset(pin)
  ArduinoUNO.onewire_reset(pin)
end

def onewire_reset?(pin)
  ArduinoUNO.onewire_reset(pin) == 1
end

def onewire_write_byte(pin, value)
  ArduinoUNO.onewire_write_byte(pin, value)
end

def onewire_read_byte(pin)
  ArduinoUNO.onewire_read_byte(pin)
end

def ds18b20_request_temperature(pin)
  ArduinoUNO.ds18b20_request_temperature(pin)
end

def ds18b20_read_temperature_x10(pin)
  ArduinoUNO.ds18b20_read_temperature_x10(pin)
end

# 16x2 character LCD on a HD44780 controller, wired in 4-bit mode.
# Pass the RS, E, and four data pins; pass cols/rows to size the display.
def lcd_begin(rs, en, d4, d5, d6, d7, cols = 16, rows = 2)
  ArduinoUNO.lcd_begin(rs, en, d4, d5, d6, d7, cols, rows)
end

def lcd_clear
  ArduinoUNO.lcd_clear
end

def lcd_home
  ArduinoUNO.lcd_home
end

def lcd_set_cursor(col, row)
  ArduinoUNO.lcd_set_cursor(col, row)
end

def lcd_write_char(char)
  ArduinoUNO.lcd_write_char(char)
end

def lcd_print_str(str)
  ArduinoUNO.lcd_print_str(str)
end

def lcd_print_int(value)
  ArduinoUNO.lcd_print_int(value)
end

# 4-wire stepper motor (full-step mode). Pass the steps-per-revolution and
# four GPIO pins wired to the coil drivers.
def stepper_begin(steps_per_revolution, p1, p2, p3, p4)
  ArduinoUNO.stepper_begin(steps_per_revolution, p1, p2, p3, p4)
end

def stepper_set_speed(rpm)
  ArduinoUNO.stepper_set_speed(rpm)
end

def stepper_step(steps)
  ArduinoUNO.stepper_step(steps)
end

# Bit-banged software serial. Single instance, half-duplex. Useful for
# talking to GPS modules, ESP-01, GSM modules, and similar peripherals
# while the hardware UART is busy.
def soft_serial_begin(rx_pin, tx_pin, baud)
  ArduinoUNO.soft_serial_begin(rx_pin, tx_pin, baud)
end

def soft_serial_write(byte)
  ArduinoUNO.soft_serial_write(byte)
end

def soft_serial_print_str(s)
  ArduinoUNO.soft_serial_print_str(s)
end

def soft_serial_read
  ArduinoUNO.soft_serial_read
end

# IR remote receiver (NEC protocol). Returns 0 on success, negative on
# timeout/parse error. Pair with `ir_command` to read the decoded command.
def ir_receive(pin, timeout_ms = 100)
  ArduinoUNO.ir_receive(pin, timeout_ms)
end

def ir_receive?(pin, timeout_ms = 100)
  ArduinoUNO.ir_receive(pin, timeout_ms) == 0
end

def ir_command
  ArduinoUNO.ir_command
end

# ---------------------------------------------------------------------------
# Ruby-style module facades.
#
# Each facade is a thin module-method wrapper around the snake_case top-level
# methods above, giving sketches a more namespaced feel:
#
#   Pin.mode(13, ArduinoUno::OUTPUT)
#   Serial.begin(9600); Serial.println(42)
#   Eeprom.write(0, 0xAB); v = Eeprom.read(0)
#   Spi.begin; r = Spi.transfer(0x9F)
#   Wire.begin; Wire.transmit(0x68); Wire.write(0x6B); Wire.end_transmission
#   Servo.attach(9); Servo.angle = 90
#
# The Arduino-named top-level functions remain the canonical compatibility
# layer for porting .ino sketches.
#
# Spinel monomorphizes module methods, so polymorphic-looking helpers (e.g.
# a single Serial.print used with both String and Integer) need to live at
# top level via the codegen — Serial.print_str / print_int / print_hex etc.
# split those out so each facade method has a single static type.
# ---------------------------------------------------------------------------

module Pin
  def self.mode(pin, mode); pin_mode(pin, mode); end
  def self.write(pin, value); digital_write(pin, value); end
  def self.read(pin); digital_read(pin); end
  def self.high(pin); digital_write(pin, 1); end
  def self.low(pin); digital_write(pin, 0); end
  def self.high?(pin); digital_read(pin) == 1; end
  def self.low?(pin); digital_read(pin) == 0; end
  def self.analog_read(pin); analog_read(pin); end
  def self.analog_write(pin, value); analog_write(pin, value); end
  def self.pulse_in(pin, value, timeout_us = 1_000_000); pulse_in_timeout(pin, value, timeout_us); end
end

module Serial
  def self.begin(baud); serial_begin(baud); end
  def self.end; serial_end; end
  def self.available; serial_available; end
  def self.available?; serial_available > 0; end
  def self.available_for_write; serial_available_for_write; end
  def self.read; serial_read; end
  def self.read_byte_timeout; serial_read_byte_timeout; end
  def self.peek; serial_peek; end
  def self.write(byte); serial_write(byte); end
  def self.flush; serial_flush; end
  def self.timeout; serial_get_timeout; end
  def self.timeout=(ms); serial_set_timeout(ms); end
  def self.parse_int; serial_parse_int; end
  def self.parse_float; serial_parse_float; end
  def self.find?(target); serial_find?(target); end
  def self.find_until?(target, terminator); serial_find_until?(target, terminator); end
  def self.print_str(s); serial_print_str(s); end
  def self.print_int(n); serial_print_int(n); end
  def self.print_hex(n); serial_print_hex(n); end
  def self.print_bin(n); serial_print_bin(n); end
  def self.print_oct(n); serial_print_oct(n); end
  def self.print_float(f, decimals); serial_print_float(f, decimals); end
  def self.println_str(s); serial_println_str(s); end
  def self.println_int(n); serial_println_int(n); end
  def self.println_hex(n); serial_println_hex(n); end
  def self.println_bin(n); serial_println_bin(n); end
  def self.println_oct(n); serial_println_oct(n); end
  def self.println_float(f, decimals); serial_println_float(f, decimals); end
end

module Eeprom
  def self.length; eeprom_length; end
  def self.read(addr); eeprom_read(addr); end
  def self.write(addr, value); eeprom_write(addr, value); end
  def self.update(addr, value); eeprom_update(addr, value); end
  def self.read_int(addr); eeprom_read_int(addr); end
  def self.write_int(addr, value); eeprom_write_int(addr, value); end
end

module Spi
  def self.begin; spi_begin; end
  def self.end; spi_end; end
  def self.bit_order=(order); spi_set_bit_order(order); end
  def self.clock_divider=(div); spi_set_clock_divider(div); end
  def self.data_mode=(mode); spi_set_data_mode(mode); end
  def self.transfer(byte); spi_transfer(byte); end
  def self.transfer16(word); spi_transfer16(word); end
end

module Wire
  def self.begin; wire_begin; end
  def self.end; wire_end; end
  def self.clock=(hz); wire_set_clock(hz); end
  def self.transmit(addr); wire_begin_transmission(addr); end
  def self.write(byte); wire_write(byte); end
  def self.end_transmission(stop = 1); wire_end_transmission(stop); end
  def self.request_from(addr, count, stop = 1); wire_request_from(addr, count, stop); end
  def self.available; wire_available; end
  def self.available?; wire_available > 0; end
  def self.read; wire_read; end
end

module Servo
  def self.attach(pin); servo_attach(pin); end
  def self.detach; servo_detach; end
  def self.angle; servo_read; end
  def self.angle=(degrees); servo_write(degrees); end
  def self.microseconds; servo_read_microseconds; end
  def self.microseconds=(us); servo_write_microseconds(us); end
  def self.attached?; servo_attached == 1; end
end
