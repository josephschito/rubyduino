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

def random_seed(seed)
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
