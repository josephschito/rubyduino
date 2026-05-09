# frozen_string_literal: true

require "test_helper"
require "rubyduino/cli"

class TestCLI < Minitest::Test
  def test_cli_module_defined
    assert defined?(Rubyduino::CLI), "Rubyduino::CLI should load"
    assert_respond_to Rubyduino::CLI, :run
  end

  def test_bin_shim_is_thin
    bin_contents = File.read(File.expand_path("../bin/rubyduino", __dir__))
    refute_match(/def usage/, bin_contents, "CLI helpers should not be top-level in bin/")
    refute_match(/def run!/, bin_contents)
    assert_match(/Rubyduino::CLI/, bin_contents)
  end

  def test_help_exits_nonzero_with_usage_message
    require "open3"
    bin = File.expand_path("../bin/rubyduino", __dir__)
    out, status = Open3.capture2e(RbConfig.ruby, bin, "--help")
    refute_predicate status, :success?, "--help should exit nonzero (usage)"
    assert_match(/Usage: rubyduino/, out)
    assert_match(/--baud BAUD/, out)
  end

  def test_no_top_level_object_pollution_from_loading_cli
    before = Object.private_instance_methods(false).to_set
    require "rubyduino/cli"
    after = Object.private_instance_methods(false).to_set
    leaked = after - before
    leaked.delete(:capture!) # might already exist if tests required something
    assert_empty leaked, "loading rubyduino/cli leaked into Object: #{leaked.to_a}"
  end
end
