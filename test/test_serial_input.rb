# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestSerialInput < Minitest::Test
  def test_codegen_emits_helpers
    sketch = <<~RUBY
      n = serial_parse_int
      f = serial_parse_float
      ok = serial_find?("READY")
      ok2 = serial_find_until?("READY", "\\n")
      b = serial_read_byte_timeout
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[serial_parse_int( serial_parse_float( serial_find( serial_find_until( serial_read_byte_timeout(].each do |fn|
      assert_includes c, fn, "missing #{fn}"
    end
  end

  def test_parse_int_logic_native
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      #include <string.h>

      static const char *fed = NULL;
      static size_t fed_pos = 0;
      static int16_t peek_buf = -1;
      static uint32_t fake_now = 0;
      static uint32_t timeout_ms = 1000;

      static uint32_t millis(void) { return fake_now; }
      static int serial_read(void) {
        if (peek_buf != -1) { int v = peek_buf; peek_buf = -1; return v; }
        if (fed && fed[fed_pos]) return (unsigned char)fed[fed_pos++];
        return -1;
      }
      static int serial_peek(void) {
        if (peek_buf != -1) return peek_buf;
        if (fed && fed[fed_pos]) { peek_buf = (unsigned char)fed[fed_pos++]; return peek_buf; }
        return -1;
      }
      static int rd_uno_serial_peek_blocking(uint32_t deadline_ms) {
        while (1) {
          int v = serial_peek();
          if (v != -1) return v;
          if (millis() >= deadline_ms) return -1;
          fake_now++;
        }
      }
      static int32_t serial_parse_int(void) {
        uint32_t deadline = millis() + timeout_ms;
        int32_t value = 0;
        int negative = 0;
        int saw = 0, v;
        for (;;) {
          v = rd_uno_serial_peek_blocking(deadline);
          if (v == -1) return 0;
          if (v == '-' || (v >= '0' && v <= '9')) break;
          serial_read();
        }
        if (v == '-') { negative = 1; serial_read(); }
        for (;;) {
          v = serial_peek();
          if (v == -1) { if (millis() >= deadline) break; else { fake_now++; continue; } }
          if (v < '0' || v > '9') break;
          value = value * 10 + (v - '0'); saw = 1; serial_read();
        }
        if (!saw) return 0;
        return negative ? -value : value;
      }
      static void reset_with(const char *s) { fed = s; fed_pos = 0; peek_buf = -1; fake_now = 0; }

      int main(void) {
        reset_with("hello-42world");
        printf("%d\\n", (int)serial_parse_int()); /* -42 */
        reset_with("  123,99");
        printf("%d\\n", (int)serial_parse_int()); /* 123 */
        reset_with("abc");
        printf("%d\\n", (int)serial_parse_int()); /* 0 (timeout) */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[-42 123 0], out.split
  end

  def test_parse_float_logic_native
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      #include <string.h>
      static const char *fed = NULL;
      static size_t fed_pos = 0;
      static int16_t peek_buf = -1;
      static uint32_t fake_now = 0;
      static uint32_t timeout_ms = 1000;
      static uint32_t millis(void) { return fake_now; }
      static int serial_read(void) {
        if (peek_buf != -1) { int v = peek_buf; peek_buf = -1; return v; }
        if (fed && fed[fed_pos]) return (unsigned char)fed[fed_pos++];
        return -1;
      }
      static int serial_peek(void) {
        if (peek_buf != -1) return peek_buf;
        if (fed && fed[fed_pos]) { peek_buf = (unsigned char)fed[fed_pos++]; return peek_buf; }
        return -1;
      }
      static int peek_blocking(uint32_t deadline) {
        while (1) {
          int v = serial_peek();
          if (v != -1) return v;
          if (millis() >= deadline) return -1;
          fake_now++;
        }
      }
      static double parse_float(void) {
        uint32_t deadline = millis() + timeout_ms;
        double value = 0.0, frac = 0.1;
        int neg = 0, dot = 0, saw = 0, v;
        for (;;) {
          v = peek_blocking(deadline);
          if (v == -1) return 0.0;
          if (v == '-' || v == '.' || (v >= '0' && v <= '9')) break;
          serial_read();
        }
        if (v == '-') { neg = 1; serial_read(); }
        for (;;) {
          v = serial_peek();
          if (v == -1) { if (millis() >= deadline) break; fake_now++; continue; }
          if (v == '.') { if (dot) break; dot = 1; serial_read(); continue; }
          if (v < '0' || v > '9') break;
          if (dot) { value += (v - '0') * frac; frac *= 0.1; }
          else { value = value * 10.0 + (v - '0'); }
          saw = 1; serial_read();
        }
        if (!saw) return 0.0;
        return neg ? -value : value;
      }
      static void reset_with(const char *s) { fed = s; fed_pos = 0; peek_buf = -1; fake_now = 0; }
      int main(void) {
        reset_with("abc-3.14xyz");
        printf("%.4f\\n", parse_float()); /* -3.1400 */
        reset_with("  42.5");
        printf("%.4f\\n", parse_float()); /* 42.5000 */
        reset_with(".25");
        printf("%.4f\\n", parse_float()); /* 0.2500 */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    lines = out.split
    assert_equal "-3.1400", lines[0]
    assert_equal "42.5000", lines[1]
    assert_equal "0.2500", lines[2]
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      serial_set_timeout(2000)

      n = serial_parse_int
      digital_write(13, n > 0 ? 1 : 0)

      f = serial_parse_float
      digital_write(12, f > 0.5 ? 1 : 0)

      digital_write(11, 1) if serial_find?("OK")
      digital_write(10, 1) if serial_find_until?("DONE", "\\n")

      b = serial_read_byte_timeout
      digital_write(9, 1) if b != -1
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
