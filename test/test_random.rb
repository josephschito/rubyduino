# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestRandom < Minitest::Test
  def test_random_seed_codegen
    sketch = "random_seed(42)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "random_seed("
  end

  def test_literal_rand_range_still_inlined
    sketch = "n = rand(1..10)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "rand() % 10"
  end

  def test_non_literal_rand_range_calls_random_range
    sketch = <<~RUBY
      low = 5
      high = 20
      n = rand(low..high)
    RUBY
    c = CompileHelper.compile_ruby_to_c(sketch)
    assert_includes c, "random_range(", "non-literal range should call random_range()"
  end

  def test_random_range_helper_callable_directly
    sketch = "n = random_range(0, 100)"
    c = CompileHelper.compile_ruby_to_c(sketch)
    # Spinel routes the top-level `def random_range` through sp_random_range,
    # which itself calls the FFI'd C `random_range`.
    assert_includes c, "sp_random_range("
    assert_includes c, "extern int32_t random_range(int32_t, int32_t);"
  end

  def test_random_range_runtime_logic
    program = <<~C
      #include <stdio.h>
      #include <stdlib.h>
      #include <stdint.h>
      static int32_t random_range(int32_t lo, int32_t hi) {
        if (hi <= lo) return lo;
        int32_t span = hi - lo;
        return lo + (int32_t)((unsigned long)rand() % (unsigned long)span);
      }
      int main(void) {
        srand(7);
        for (int i = 0; i < 200; i++) {
          int32_t v = random_range(10, 20);
          if (v < 10 || v >= 20) { printf("BAD %d\\n", v); return 1; }
        }
        /* degenerate range returns low */
        printf("%d\\n", random_range(5, 5));
        printf("%d\\n", random_range(7, 1));
        printf("OK\\n");
        return 0;
      }
    C
    out, ok = CompileHelper.run_native_program(program)
    assert ok, out
    assert_equal %w[5 7 OK], out.split
  end

  def test_avr_compile
    skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
    sketch = <<~RUBY
      random_seed(millis)
      low = 100
      high = 700
      delay_ms(rand(low..high))
      digital_write(13, random_range(0, 2))
    RUBY
    obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
    refute_empty obj
  end
end
