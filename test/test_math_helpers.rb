# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestMathHelpers < Minitest::Test
  def test_codegen_emits_helpers
    sketch = <<~RUBY
      a = map_value(512, 0, 1023, 0, 255)
      b = constrain(150, 0, 100)
      c = sq(7)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "map_value("
    assert_includes c, "constrain("
    assert_includes c, "sq("
  end

  def test_runtime_logic_against_arduino_semantics
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static int32_t map_value(int32_t v, int32_t fl, int32_t fh, int32_t tl, int32_t th) {
        int32_t fs = fh - fl;
        int32_t ts = th - tl;
        if (fs == 0) return tl;
        return (int32_t)(((int64_t)(v - fl) * (int64_t)ts) / (int64_t)fs) + tl;
      }
      static int32_t constrain_(int32_t v, int32_t lo, int32_t hi) {
        if (v < lo) return lo; if (v > hi) return hi; return v;
      }
      static int32_t sq_(int32_t v) { return v * v; }

      int main(void) {
        printf("%d\\n", map_value(512, 0, 1023, 0, 255));   /* ~127 */
        printf("%d\\n", map_value(0,   0, 1023, 0, 255));   /* 0 */
        printf("%d\\n", map_value(1023, 0, 1023, 0, 255));  /* 255 */
        printf("%d\\n", map_value(50, 0, 100, 100, 0));     /* 50 (reversed) */
        printf("%d\\n", map_value(5, 5, 5, 0, 100));        /* 0 (zero span) */
        printf("%d\\n", constrain_(150, 0, 100));           /* 100 */
        printf("%d\\n", constrain_(-5,  0, 100));           /* 0 */
        printf("%d\\n", constrain_(50,  0, 100));           /* 50 */
        printf("%d\\n", sq_(7));                             /* 49 */
        printf("%d\\n", sq_(-9));                            /* 81 */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[127 0 255 50 0 100 0 50 49 81], out.split
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      reading = analog_read(ArduinoUNO::A0)
      pwm = map_value(reading, 0, 1023, 0, 255)
      pwm = constrain(pwm, 0, 200)
      analog_write(9, pwm)
      x = sq(reading)
      digital_write(13, x & 1)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
