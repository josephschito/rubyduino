# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestWire < Minitest::Test
  HELPERS = %w[wire_begin wire_end wire_set_clock wire_begin_transmission
               wire_write wire_end_transmission wire_request_from
               wire_available wire_read].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      wire_begin
      wire_set_clock(400_000)

      wire_begin_transmission(0x68)
      wire_write(0x6B)
      wire_write(0)
      err = wire_end_transmission

      n = wire_request_from(0x68, 6)
      while wire_available > 0
        b = wire_read
      end

      wire_end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_twbr_calculation
    # TWBR = (F_CPU/freq - 16)/2 with prescaler=1.
    # Common values:
    #   16MHz, 100kHz -> 72
    #   16MHz, 400kHz -> 12
    # Frequencies < ~31 kHz overflow the 8-bit register; users wanting
    # those should bit-bang or accept the truncated value.
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static uint8_t calc_twbr(uint32_t f_cpu, uint32_t hz) {
        return (uint8_t)(((f_cpu / hz) - 16UL) / 2UL);
      }
      int main(void) {
        printf("%u\\n", (unsigned)calc_twbr(16000000UL, 100000UL));
        printf("%u\\n", (unsigned)calc_twbr(16000000UL, 400000UL));
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[72 12], out.split
  end

  def test_default_stop_arg_propagates
    sketch = <<~RUBY
      wire_begin_transmission(0x50)
      wire_write(0xAA)
      err = wire_end_transmission
      data = wire_request_from(0x50, 4)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    # default stop arg = 1 reaches both wrappers
    assert_match(/sp_wire_end_transmission\(1LL\)/, c)
    assert_match(/sp_wire_request_from\(80LL, 4LL, 1LL\)/, c)
  end

  def test_avr_compile_full_master_flow
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      wire_begin
      wire_set_clock(100_000)

      addr = 0x68
      wire_begin_transmission(addr)
      wire_write(0x6B)
      wire_write(0)
      err = wire_end_transmission

      digital_write(13, err == 0 ? 1 : 0)

      wire_begin_transmission(addr)
      wire_write(0x3B)
      wire_end_transmission(0)
      n = wire_request_from(addr, 6)
      sum = 0
      while wire_available > 0
        sum = sum + wire_read
      end
      digital_write(12, sum > 0 ? 1 : 0)

      wire_end
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
