# frozen_string_literal: true

require_relative "lib/rubyduino/version"

Gem::Specification.new do |spec|
  spec.name = "rubyduino"
  spec.version = Rubyduino::VERSION
  spec.authors = ["Joseph Schito"]
  spec.email = ["joseph.schito@gmail.com"]

  spec.summary = "Compile Ruby sketches for Arduino boards."
  spec.description = "Rubyduino compiles Ruby code for Arduino boards " \
                     "and uploads the generated firmware over a serial port."
  spec.homepage = "https://github.com/josephschito/rubyduino"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # `git ls-files` records submodules as a single gitlink, so vendor/spinel
  # needs to be expanded explicitly to ship the pinned Spinel snapshot.
  gemspec = File.basename(__FILE__)
  tracked_files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        (f == "vendor/spinel") ||
        f.start_with?(*%w[Gemfile .gitignore test/ .github/ .rubocop.yml]) ||
        %w[bin/console bin/setup].include?(f)
    end
  end

  spinel_files = Dir.glob(File.join(__dir__, "vendor/spinel/**/*"), File::FNM_DOTMATCH).filter_map do |path|
    relative_path = path.delete_prefix("#{__dir__}/")
    next unless File.file?(path)
    next if relative_path.include?("/.git/")
    next if relative_path.start_with?("vendor/spinel/.git")
    next if relative_path.start_with?("vendor/spinel/build/")
    next if relative_path.start_with?("vendor/spinel/vendor/prism/")
    next if relative_path.start_with?("vendor/spinel/.ruby-lsp/")

    relative_path
  end

  rubyduino_files = Dir.glob(
    [
      File.join(__dir__, "bin/rubyduino"),
      File.join(__dir__, "lib/rubyduino/**/*"),
      File.join(__dir__, "examples/**/*.rb")
    ],
    File::FNM_DOTMATCH
  ).filter_map do |path|
    next unless File.file?(path)

    path.delete_prefix("#{__dir__}/")
  end

  spec.files = (tracked_files + rubyduino_files + spinel_files).uniq.sort
  spec.bindir = "bin"
  spec.executables = ["rubyduino"]
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
