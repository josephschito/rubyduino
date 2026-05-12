# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestSPI < Minitest::Test
  HELPERS = %w[spi_begin spi_end spi_set_bit_order spi_set_clock_divider
               spi_set_data_mode spi_transfer spi_transfer16].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      spi_begin
      spi_set_data_mode(ArduinoUNO::SPI_MODE0)
      spi_set_clock_divider(ArduinoUNO::SPI_CLOCK_DIV4)
      spi_set_bit_order(ArduinoUNO::MSBFIRST)
      r = spi_transfer(0xAB)
      r2 = spi_transfer16(0x1234)
      spi_end
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_clock_divider_table_logic_native
    program = <<~C
      #include <stdio.h>
      #include <stdint.h>
      static uint8_t SPCR = 0, SPSR = 0;
      #define SPR1 1
      #define SPR0 0
      #define SPI2X 0
      static void set_div(uint8_t divider) {
        uint8_t spr = (uint8_t)(divider & 0x03);
        uint8_t spi2x = (divider >= 4) ? 1 : 0;
        SPCR = (uint8_t)((SPCR & (uint8_t)~((1 << SPR1) | (1 << SPR0))) | spr);
        if (spi2x) SPSR |= (uint8_t)(1 << SPI2X);
        else SPSR &= (uint8_t)~(1 << SPI2X);
      }
      int main(void) {
        for (uint8_t d = 0; d <= 6; d++) {
          SPCR = 0; SPSR = 0;
          set_div(d);
          printf("d=%u SPCR=%u SPSR=%u\\n", (unsigned)d, (unsigned)(SPCR & 0x03), (unsigned)(SPSR & 1));
        }
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    expected = [
      "d=0 SPCR=0 SPSR=0",   # DIV4
      "d=1 SPCR=1 SPSR=0",   # DIV16
      "d=2 SPCR=2 SPSR=0",   # DIV64
      "d=3 SPCR=3 SPSR=0",   # DIV128
      "d=4 SPCR=0 SPSR=1",   # DIV2
      "d=5 SPCR=1 SPSR=1",   # DIV8
      "d=6 SPCR=2 SPSR=1"    # DIV32
    ]
    assert_equal expected, out.lines.map(&:strip)
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      cs = 9
      pin_mode(cs, ArduinoUNO::OUTPUT)
      digital_write(cs, ArduinoUNO::HIGH)

      spi_begin
      spi_set_data_mode(ArduinoUNO::SPI_MODE0)
      spi_set_clock_divider(ArduinoUNO::SPI_CLOCK_DIV16)
      spi_set_bit_order(ArduinoUNO::MSBFIRST)

      digital_write(cs, ArduinoUNO::LOW)
      reply = spi_transfer(0x9F)
      reply16 = spi_transfer16(0x0000)
      digital_write(cs, ArduinoUNO::HIGH)

      spi_end

      digital_write(13, reply > 0 ? 1 : 0)
      digital_write(12, reply16 > 0 ? 1 : 0)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
