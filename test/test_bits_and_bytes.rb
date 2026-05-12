# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestBitsAndBytes < Minitest::Test
  def test_codegen_emits_bit_helpers_as_c_calls
    sketch = <<~RUBY
      mask = bit(3)
      b = bit_read(mask, 3)
      mask = bit_set(mask, 5)
      mask = bit_clear(mask, 3)
      mask = bit_write(mask, 0, 1)
      hi = high_byte(0xABCD)
      lo = low_byte(0xABCD)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    %w[bit( bit_read( bit_set( bit_clear( bit_write( high_byte( low_byte(].each do |fn|
      assert_includes c, fn, "expected #{fn}…) call in generated C"
    end
  end

  def test_runtime_logic_against_arduino_semantics
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static uint32_t bit_set(uint32_t v, uint8_t n) { return v | ((uint32_t)1 << n); }
      static uint32_t bit_clear(uint32_t v, uint8_t n) { return v & (uint32_t)~((uint32_t)1 << n); }
      static uint32_t bit_write(uint32_t v, uint8_t n, uint8_t b) { return b ? bit_set(v, n) : bit_clear(v, n); }
      static uint8_t  bit_read(uint32_t v, uint8_t n) { return (uint8_t)((v >> n) & 1u); }
      static uint32_t bit_(uint8_t n) { return (uint32_t)1 << n; }
      static uint8_t  high_byte(uint16_t v) { return (uint8_t)((v >> 8) & 0xFFu); }
      static uint8_t  low_byte(uint16_t v) { return (uint8_t)(v & 0xFFu); }

      int main(void) {
        printf("%lu\\n", (unsigned long)bit_(0));      /* 1 */
        printf("%lu\\n", (unsigned long)bit_(7));      /* 128 */
        printf("%u\\n",  bit_read(0b10100000u, 7));    /* 1 */
        printf("%u\\n",  bit_read(0b10100000u, 6));    /* 0 */
        printf("%lu\\n", (unsigned long)bit_set(0u, 4));        /* 16 */
        printf("%lu\\n", (unsigned long)bit_clear(0xFFu, 0));   /* 254 */
        printf("%lu\\n", (unsigned long)bit_write(0xF0u, 0, 1));/* 241 */
        printf("%lu\\n", (unsigned long)bit_write(0xF0u, 4, 0));/* 224 */
        printf("%u\\n",  high_byte(0xABCD)); /* 171 */
        printf("%u\\n",  low_byte(0xABCD));  /* 205 */
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, "native compile failed:\n#{out}"
    assert_equal %w[1 128 1 0 16 254 241 224 171 205], out.split
  end

  def test_avr_sketch_compiles
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      x = bit(3)
      x = bit_set(x, 1)
      x = bit_clear(x, 0)
      x = bit_write(x, 7, 1)
      r = bit_read(x, 7)
      h = high_byte(0xABCD)
      l = low_byte(0xABCD)
      digital_write(13, r)
      digital_write(12, h & 1)
      digital_write(11, l & 1)
    RUBY
    obj_bytes = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj_bytes
  end
end
