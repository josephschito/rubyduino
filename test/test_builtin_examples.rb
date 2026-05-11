# frozen_string_literal: true

require "test_helper"
require "support/compile_helper"

class TestBuiltinExamples < Minitest::Test
  ROOT_EXAMPLES = File.expand_path("../examples", __dir__)

  # Auto-generate a compile test for every sketch under examples/. This
  # catches "sketch shipped but doesn't actually parse / link" regressions
  # for the curated example library and the ThinkerShield Crack the Code
  # ports. The two glob arms cover nested dirs (builtin/01_basics/...) and
  # the loose root sketches (examples/hello.rb).
  SKETCH_GLOBS = [
    File.join(ROOT_EXAMPLES, "{builtin,hardware,crack_the_code}", "**", "*.rb"),
    File.join(ROOT_EXAMPLES, "*.rb")
  ].freeze

  SKETCH_GLOBS.flat_map { |g| Dir.glob(g) }.sort.uniq.each do |path|
    rel = path.sub("#{File.dirname(ROOT_EXAMPLES)}/", "")
    test_name = "test_#{rel.gsub(%r{[/.]}, "_")}_compiles"
    define_method(test_name) do
      skip "avr-gcc not installed" unless CompileHelper.avr_gcc_available?
      sketch = File.read(path)
      obj = CompileHelper.compile_ruby_to_avr_obj(sketch)
      refute_empty obj, "empty obj for #{rel}"
    end
  end

  def test_examples_dirs_have_sketches
    builtin   = Dir.glob(File.join(ROOT_EXAMPLES, "builtin", "*", "*.rb"))
    hardware  = Dir.glob(File.join(ROOT_EXAMPLES, "hardware", "*.rb"))
    crack     = Dir.glob(File.join(ROOT_EXAMPLES, "crack_the_code", "*.rb"))
    assert_operator builtin.length,  :>=, 35, "expected at least 35 builtin example sketches"
    assert_operator hardware.length, :>=,  7, "expected at least 7 hardware example sketches"
    assert_operator crack.length,    :>=, 18, "expected at least 18 Crack the Code sketches"
  end
end
