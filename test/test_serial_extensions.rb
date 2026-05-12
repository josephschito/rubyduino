# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestSerialExtensions < Minitest::Test
  HELPERS = %w[serial_end serial_flush serial_peek serial_available_for_write
               serial_set_timeout serial_get_timeout].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      serial_set_timeout(500)
      t = serial_get_timeout
      n = serial_peek
      avail = serial_available_for_write
      serial_flush
      serial_end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h} in generated C" }
  end

  def test_peek_buffer_logic_native
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static int16_t peek_buf = -1;
      static int incoming = -1;
      static int rxc(void) { return incoming != -1 ? 1 : 0; }
      static int udr(void) { int v = incoming; incoming = -1; return v; }

      static int serial_available(void) { return peek_buf != -1 ? 1 : (rxc() ? 1 : 0); }
      static int serial_peek(void) {
        if (peek_buf != -1) return peek_buf;
        if (!rxc()) return -1;
        peek_buf = (int16_t)udr();
        return peek_buf;
      }
      static int serial_read(void) {
        int v;
        if (peek_buf != -1) { v = peek_buf; peek_buf = -1; return v; }
        if (!rxc()) return -1;
        return udr();
      }

      int main(void) {
        printf("%d\\n", serial_available()); /* 0 */
        printf("%d\\n", serial_peek());      /* -1 */
        incoming = 'A';
        printf("%d\\n", serial_available()); /* 1 (rxc) */
        printf("%d\\n", serial_peek());      /* 65 - now buffered */
        printf("%d\\n", serial_peek());      /* 65 again - still buffered */
        printf("%d\\n", serial_available()); /* 1 (peek_buf) */
        printf("%d\\n", serial_read());      /* 65 - consumed */
        printf("%d\\n", serial_available()); /* 0 */
        printf("%d\\n", serial_read());      /* -1 */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[0 -1 1 65 65 1 65 0 -1], out.split
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      serial_begin(9600)
      serial_set_timeout(2000)
      timeout = serial_get_timeout
      ch = serial_peek
      if ch != -1 && serial_available_for_write == 1
        serial_write(ch)
      end
      serial_flush
      serial_end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
