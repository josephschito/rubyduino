# frozen_string_literal: true

require "test_helper"

class TestCodegenModuleShape < Minitest::Test
  CODEGEN_FILE = File.expand_path("../lib/rubyduino/spinel_arduino_codegen.rb", __dir__)

  def test_no_top_level_load_helper
    src = File.read(CODEGEN_FILE)
    refute_match(/^def load_spinel_compiler/, src,
                 "load_spinel_compiler should live inside SpinelArduinoCodegen, not top level")
  end

  def test_loader_callable_through_module
    src = File.read(CODEGEN_FILE)
    assert_match(/SpinelArduinoCodegen\.load_spinel_compiler/, src)
    assert_match(/def self\.load_spinel_compiler/, src)
  end

  def test_module_is_namespaced
    src = File.read(CODEGEN_FILE)
    assert_match(/^module SpinelArduinoCodegen$/, src)
    assert_match(/SPINEL_ROOT = File\.join\(ROOT, "vendor\/spinel"\)/, src)
  end
end
