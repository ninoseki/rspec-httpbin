# frozen_string_literal: true

require_relative "lib/rspec/httpbin/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-httpbin"
  spec.version = RSpec::HTTPBin::VERSION
  spec.authors = ["Manabu Niseki"]
  spec.email = ["manabu.niseki@gmail.com"]

  spec.summary = "An httpbin like Rack module for RSpec"
  spec.description = "An httpbin like Rack module for Rspec"
  spec.homepage = "https://github.com/ninoseki/rspec-httpbin"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "capybara", "~> 3.40"
  spec.add_development_dependency "fuubar", "~> 2.5.1"
  spec.add_development_dependency "http", "~> 5.2.0"
  spec.add_development_dependency "puma", "~> 6.4.2"
  spec.add_development_dependency "rack", "~> 3.0.11"
  spec.add_development_dependency "rack-test", "~> 2.1.0"
  spec.add_development_dependency "rackup", "~> 2.1.0"
  spec.add_development_dependency "rake", "~> 13.2.1"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rspec-parameterized", "~> 1.0.2"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.31.0"
  spec.add_development_dependency "rubocop-yard", "~> 0.9.3"
  spec.add_development_dependency "standard", "~> 1.36.0"
  spec.add_development_dependency "lefthook", "~> 1.6"
end
