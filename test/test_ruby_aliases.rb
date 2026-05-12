# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestRubyAliases < Minitest::Test
  PREDICATES = %w[
    alpha? digit? alphanumeric? space? whitespace? uppercase?
    lowercase? ascii? control? printable? punctuation? hex_digit? graph?
  ].freeze

  def test_predicate_aliases_compile
    sketch_lines = ["c = serial_read"]
    PREDICATES.each_with_index do |pred, i|
      sketch_lines << "digital_write(#{i + 2}, 1) if #{pred}(c)"
    end
    c = CompileHelper.compile_ruby_to_c(sketch_lines.join("\n"))
    PREDICATES.each do |pred|
      sym = "sp_#{pred.delete_suffix("?")}_p"
      assert_includes c, sym, "expected #{sym} in generated C"
    end
  end

  def test_clamp_alias_routes_to_constrain
    c = CompileHelper.compile_ruby_to_c("v = clamp(150, 0, 100)")
    assert_includes c, "constrain("
    assert_includes c, "sp_clamp("
  end

  def test_square_alias_routes_to_sq
    c = CompileHelper.compile_ruby_to_c("v = square(7)")
    assert_includes c, "sq("
    assert_includes c, "sp_square("
  end

  def test_sleep_aliases_route_to_delay
    c = CompileHelper.compile_ruby_to_c("sleep_ms(100); sleep_us(50)")
    assert_includes c, "delay_ms("
    assert_includes c, "delay_us("
    assert_includes c, "sp_sleep_ms("
    assert_includes c, "sp_sleep_us("
  end

  def test_srand_aliases_random_seed
    c = CompileHelper.compile_ruby_to_c("srand(42)")
    assert_includes c, "random_seed("
    assert_includes c, "sp_srand("
  end

  def test_stop_tone_aliases_no_tone
    c = CompileHelper.compile_ruby_to_c("stop_tone(8)")
    assert_includes c, "no_tone("
    assert_includes c, "sp_stop_tone("
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      srand(millis)
      sleep_ms(100)
      sleep_us(50)
      stop_tone(8)
      v = clamp(150, 0, 100)
      x = square(9)
      ch = serial_read
      digital_write(13, 1) if alpha?(ch)
      digital_write(12, 1) if digit?(ch)
      digital_write(11, 1) if hex_digit?(ch)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
