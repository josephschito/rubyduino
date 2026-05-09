# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestCharClassification < Minitest::Test
  HELPERS = %i[
    is_alpha is_digit is_alpha_numeric is_space is_whitespace
    is_upper_case is_lower_case is_ascii is_control is_printable
    is_punct is_hexadecimal_digit is_graph
  ].freeze

  def test_codegen_emits_each_helper
    sketch = HELPERS.map { |h| "x = #{h}(65)" }.join("\n")
    c = CompileHelper.compile_ruby_to_c(sketch)
    HELPERS.each { |h| assert_includes c, "#{h}(", "missing #{h}" }
  end

  def test_runtime_logic_against_arduino_semantics
    program = <<~C
      #include <stdio.h>
      static int is_alpha(int c){return ((c>='A'&&c<='Z')||(c>='a'&&c<='z'))?1:0;}
      static int is_digit(int c){return (c>='0'&&c<='9')?1:0;}
      static int is_alpha_numeric(int c){return (is_alpha(c)||is_digit(c))?1:0;}
      static int is_space(int c){return (c==' '||c=='\\t'||c=='\\n'||c=='\\v'||c=='\\f'||c=='\\r')?1:0;}
      static int is_whitespace(int c){return (c==' '||c=='\\t')?1:0;}
      static int is_upper_case(int c){return (c>='A'&&c<='Z')?1:0;}
      static int is_lower_case(int c){return (c>='a'&&c<='z')?1:0;}
      static int is_ascii(int c){return (c>=0&&c<=127)?1:0;}
      static int is_control(int c){return ((c>=0&&c<=31)||c==127)?1:0;}
      static int is_printable(int c){return (c>=32&&c<=126)?1:0;}
      static int is_punct(int c){
        if(c>='!'&&c<='/')return 1;
        if(c>=':'&&c<='@')return 1;
        if(c>='['&&c<='`')return 1;
        if(c>='{'&&c<='~')return 1;
        return 0;
      }
      static int is_hexadecimal_digit(int c){
        if(c>='0'&&c<='9')return 1;
        if(c>='a'&&c<='f')return 1;
        if(c>='A'&&c<='F')return 1;
        return 0;
      }
      int main(void){
        printf("%d %d %d %d %d %d %d %d %d %d %d %d\\n",
          is_alpha('A'),    /* 1 */
          is_alpha('5'),    /* 0 */
          is_digit('7'),    /* 1 */
          is_alpha_numeric('z'), /* 1 */
          is_space('\\n'),  /* 1 */
          is_whitespace('\\n'), /* 0 - only space/tab */
          is_upper_case('q'), /* 0 */
          is_lower_case('q'), /* 1 */
          is_ascii(200),    /* 0 */
          is_control(0x1B), /* 1 */
          is_printable(' '),/* 1 */
          is_punct(','));   /* 1 */
        printf("%d %d %d\\n",
          is_hexadecimal_digit('F'),
          is_hexadecimal_digit('g'),
          is_hexadecimal_digit('9'));
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    lines = out.lines.map(&:strip)
    assert_equal "1 0 1 1 1 0 0 1 0 1 1 1", lines[0]
    assert_equal "1 0 1", lines[1]
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      ch = serial_read
      digital_write(13, 1) if is_alpha(ch) == 1
      digital_write(12, 1) if is_digit(ch) == 1
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end

  def test_predicate_aliases_compile
    sketch = <<~RUBY
      ch = serial_read
      digital_write(13, 1) if is_alpha?(ch)
      digital_write(12, 1) if is_digit?(ch)
      digital_write(11, 1) if is_hexadecimal_digit?(ch)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    # Predicate aliases route through sp_is_*_p inline functions.
    assert_includes c, "sp_is_alpha_p("
    assert_includes c, "sp_is_digit_p("
    assert_includes c, "sp_is_hexadecimal_digit_p("
  end

  def test_predicate_aliases_compile_to_avr
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      ch = serial_read
      digital_write(13, 1) if is_alpha?(ch)
      digital_write(12, 1) if is_space?(ch)
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
