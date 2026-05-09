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
