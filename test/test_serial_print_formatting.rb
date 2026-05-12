# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestSerialPrintFormatting < Minitest::Test
  def test_codegen_routes_hex_bin_oct
    sketch = <<~RUBY
      serial_print(255, ArduinoUNO::HEX)
      serial_print(7, ArduinoUNO::BIN)
      serial_print(63, ArduinoUNO::OCT)
      serial_println(255, ArduinoUNO::HEX)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "serial_print_hex("
    assert_includes c, "serial_print_bin("
    assert_includes c, "serial_print_oct("
    assert_includes c, "serial_println_hex("
  end

  def test_codegen_routes_dec_to_int
    sketch = "serial_print(42, ArduinoUNO::DEC)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "serial_print_int("
  end

  def test_codegen_routes_float_with_decimals
    sketch = "serial_print(3.14, 4)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "serial_print_float("
    assert_match(/serial_print_float\(\(double\)\([^)]+\), \(uint8_t\)\([^)]+\)\)/, c)
  end

  def test_explicit_helpers_codegen
    sketch = <<~RUBY
      serial_print_hex(0xCAFE)
      serial_print_bin(0b101)
      serial_println_float(2.5, 3)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "sp_serial_print_hex("
    assert_includes c, "sp_serial_print_bin("
    assert_includes c, "sp_serial_println_float("
  end

  def test_hex_bin_oct_runtime_logic
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static char out[256];
      static int out_pos = 0;
      static void put_char(char c) { out[out_pos++] = c; out[out_pos] = 0; }
      static void serial_print_str(const char *s) { while (*s) put_char(*s++); }
      static void rd_uno_print_unsigned_base(uint32_t value, uint8_t base) {
        char buf[33]; char *p = &buf[32]; uint32_t v = value;
        *p = 0;
        if (base < 2) base = 10;
        do {
          p--;
          uint8_t digit = (uint8_t)(v % base);
          *p = (char)((digit < 10) ? ('0' + digit) : ('A' + (digit - 10)));
          v /= base;
        } while (v > 0);
        serial_print_str(p);
      }
      int main(void) {
        rd_uno_print_unsigned_base(255, 16); put_char(' ');
        rd_uno_print_unsigned_base(7, 2); put_char(' ');
        rd_uno_print_unsigned_base(63, 8); put_char(' ');
        rd_uno_print_unsigned_base(0, 16); put_char(' ');
        rd_uno_print_unsigned_base(0xCAFE, 16);
        printf("%s\\n", out);
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal "FF 111 77 0 CAFE", out.strip
  end

  def test_float_formatter_runtime_logic
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static char buf[256]; static int p = 0;
      static void emit(char c) { buf[p++] = c; buf[p] = 0; }
      static void serial_write(uint8_t c) { emit((char)c); }
      static void serial_print_str(const char *s) { while (*s) emit(*s++); }
      static void serial_print_int(int v) {
        char tmp[12]; int i = 0;
        if (v < 0) { emit('-'); v = -v; }
        if (v == 0) tmp[i++] = '0';
        while (v) { tmp[i++] = '0' + (v % 10); v /= 10; }
        while (i--) emit(tmp[i]);
      }
      static void rd_print_float(double v, uint8_t d) {
        if (v < 0.0) { serial_write('-'); v = -v; }
        double r = 0.5; for (uint8_t i = 0; i < d; i++) r /= 10.0;
        v += r;
        uint32_t ip = (uint32_t)v;
        double rem = v - (double)ip;
        serial_print_int((int)ip);
        if (d > 0) {
          serial_write('.');
          while (d--) {
            rem *= 10.0;
            uint8_t digit = (uint8_t)rem;
            serial_write('0' + digit);
            rem -= (double)digit;
          }
        }
      }
      int main(void) {
        rd_print_float(3.14159, 2); emit(' ');
        rd_print_float(-2.5, 1); emit(' ');
        rd_print_float(0.0, 3); emit(' ');
        rd_print_float(0.999, 2); /* round to 1.00 */
        printf("%s\\n", buf);
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal "3.14 -2.5 0.000 1.00", out.strip
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      serial_print("addr=0x")
      serial_println(0x2A, ArduinoUNO::HEX)
      serial_print("flags=")
      serial_println(0b10110, ArduinoUNO::BIN)
      serial_print("temp=")
      serial_println(23.5, 2)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
