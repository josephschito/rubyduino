# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestTone < Minitest::Test
  def test_codegen_emits_tone_and_no_tone
    sketch = <<~RUBY
      tone(8, 440)
      tone(8, 440, 500)
      no_tone(8)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "tone_for("
    assert_includes c, "no_tone("
    # default duration arg of 0 reaches sp_tone wrapper
    assert_match(/sp_tone\(8LL, 440LL, 0LL\)/, c)
    assert_match(/sp_tone\(8LL, 440LL, 500LL\)/, c)
  end

  def test_avr_compile_continuous_tone
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      tone(8, 1000)
      delay_ms(500)
      no_tone(8)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end

  def test_avr_compile_with_duration
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = "tone(8, 440, 250)"
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end

  def test_elf_contains_tone_isr
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = "tone(8, 440, 250)"
    elf_data = nil
    CompileHelper.compile_ruby_to_avr_elf(sketch) do |elf, _, _|
      elf_data = CompileHelper.avr_objdump_disassembly(elf)
    end
    assert_includes elf_data, "__vector_7", "expected TIMER2_COMPA ISR (vector 7) in elf"
  end
end
