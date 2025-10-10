require_relative "lib/kreds/version"

Gem::Specification.new do |spec|
  spec.name = "kreds"
  spec.version = Kreds::VERSION
  spec.authors = ["enjaku4"]
  spec.email = ["enjaku4@icloud.com"]
  spec.homepage = "https://github.com/enjaku4/kreds"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.summary = "The missing shorthand for Rails credentials"
  spec.description = "Kreds provides a simpler, shorter, and safer way to access Rails credentials with clear error messages, environment variable fallback support, and blank value detection"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2", "< 3.5"

  spec.files = [
    "kreds.gemspec", "README.md", "CHANGELOG.md", "LICENSE.txt"
  ] + Dir.glob("lib/**/*")

  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "rails", ">= 7.1", "< 8.1"
end
