# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestExternalInterrupts < Minitest::Test
  def test_codegen_emits_helpers
    sketch = <<~RUBY
      n = digital_pin_to_interrupt(2)
      attach_interrupt(n, ArduinoUNO::INT_RISING)
      if interrupt_fired?(n)
        digital_write(13, 1)
      end
      detach_interrupt(n)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "attach_interrupt("
    assert_includes c, "detach_interrupt("
    assert_includes c, "digital_pin_to_interrupt("
    assert_includes c, "interrupt_fired("
  end

  def test_digital_pin_to_interrupt_table
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static int8_t digital_pin_to_interrupt(uint8_t pin) {
        if (pin == 2) return 0;
        if (pin == 3) return 1;
        return -1;
      }
      int main(void) {
        int8_t r;
        for (uint8_t p = 0; p <= 13; p++) {
          r = digital_pin_to_interrupt(p);
          printf("%u:%d\\n", (unsigned)p, (int)r);
        }
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    expected = (0..13).map { |p| "#{p}:#{p == 2 ? 0 : p == 3 ? 1 : -1}" }
    assert_equal expected, out.lines.map(&:strip)
  end

  def test_avr_compile_with_isrs
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      pin_mode(2, ArduinoUNO::INPUT_PULLUP)
      pin_mode(3, ArduinoUNO::INPUT_PULLUP)
      pin_mode(13, ArduinoUNO::OUTPUT)

      attach_interrupt(digital_pin_to_interrupt(2), ArduinoUNO::INT_FALLING)
      attach_interrupt(digital_pin_to_interrupt(3), ArduinoUNO::INT_RISING)

      loop do
        digital_write(13, 1) if interrupt_fired?(0)
        digital_write(12, 1) if interrupt_fired?(1)
        delay_ms(10)
      end
    RUBY
    elf = nil
    CompileHelper.compile_ruby_to_avr_elf(sketch) do |path, _, _|
      elf = CompileHelper.avr_objdump_disassembly(path)
    end
    # ATmega328P INT0 = vector 1, INT1 = vector 2 (in avr-libc, vector_1 / vector_2)
    assert_includes elf, "__vector_1", "INT0 ISR not in elf"
    assert_includes elf, "__vector_2", "INT1 ISR not in elf"
  end
end
