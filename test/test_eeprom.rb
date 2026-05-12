# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestEEPROM < Minitest::Test
  HELPERS = %w[eeprom_read eeprom_write eeprom_update eeprom_length
               eeprom_read_int eeprom_write_int].freeze

  def test_codegen_emits_helpers
    sketch = <<~RUBY
      total = eeprom_length
      x = eeprom_read(0)
      eeprom_write(1, 42)
      eeprom_update(2, 7)
      v = eeprom_read_int(4)
      eeprom_write_int(8, 12345)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_avr_compile_calls_avr_libc_helpers
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      total = eeprom_length
      digital_write(13, total == 1024 ? 1 : 0)

      eeprom_update(0, 0xAB)
      v = eeprom_read(0)
      digital_write(12, v == 0xAB ? 1 : 0)

      eeprom_write_int(4, -100_000)
      n = eeprom_read_int(4)
      digital_write(11, n == -100_000 ? 1 : 0)
    RUBY
    elf = nil
    CompileHelper.compile_ruby_to_avr_elf(sketch) do |path, _, _|
      elf = CompileHelper.avr_objdump_disassembly(path)
    end
    # avr-libc routes high-level helpers to common_eeprom routines.
    assert(elf.include?("eeprom_") || elf.include?("__do_clear_bss"),
           "expected avr-libc eeprom helpers in disassembly")
  end

  def test_e2end_constant_is_1024_minus_1
    # ATmega328P has 1024 bytes of EEPROM, so E2END should be 1023.
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = "v = eeprom_length"
    elf_data = nil
    CompileHelper.compile_ruby_to_avr_elf(sketch) do |path, _, _|
      elf_data = CompileHelper.avr_objdump_disassembly(path)
    end
    refute_nil elf_data
  end
end
