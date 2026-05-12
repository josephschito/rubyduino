# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestServo < Minitest::Test
  HELPERS = %w[servo_attach servo_detach servo_write servo_write_microseconds
               servo_read servo_read_microseconds servo_attached].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      servo_attach(9)
      servo_write(90)
      servo_write_microseconds(1750)
      angle = servo_read
      us = servo_read_microseconds
      digital_write(13, 1) if servo_attached?
      servo_detach
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_angle_to_microseconds_mapping_native
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static int32_t map_value(int32_t v, int32_t fl, int32_t fh, int32_t tl, int32_t th) {
        int32_t fs = fh - fl, ts = th - tl;
        if (fs == 0) return tl;
        return (int32_t)(((int64_t)(v - fl) * (int64_t)ts) / (int64_t)fs) + tl;
      }
      int main(void) {
        printf("%d\\n", (int)map_value(0,   0, 180, 544, 2400));   /* 544 */
        printf("%d\\n", (int)map_value(90,  0, 180, 544, 2400));   /* 1472 */
        printf("%d\\n", (int)map_value(180, 0, 180, 544, 2400));   /* 2400 */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[544 1472 2400], out.split
  end

  def test_avr_compile_with_isr
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      servo_attach(9)
      servo_write(0)
      delay_ms(500)
      servo_write(90)
      delay_ms(500)
      servo_write(180)
      delay_ms(500)
      digital_write(13, 1) if servo_attached?
      servo_detach
    RUBY
    elf = nil
    CompileHelper.compile_ruby_to_avr_elf(sketch) do |path, _, _|
      elf = CompileHelper.avr_objdump_disassembly(path)
    end
    # ATmega328P TIMER1_COMPA = vector 11
    assert_includes elf, "__vector_11", "expected TIMER1_COMPA ISR in elf"
  end
end
