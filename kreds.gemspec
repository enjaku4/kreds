require_relative "lib/kreds/version"

Gem::Specification.new do |spec|
  spec.name = "kreds"
  spec.version = Kreds::VERSION
  spec.authors = ["enjaku4"]
  spec.homepage = "https://github.com/enjaku4/kreds"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.summary = "The missing shorthand for Rails credentials"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1", "< 3.5"

  spec.files = [
    "kreds.gemspec", "README.md", "CHANGELOG.md", "LICENSE.txt"
  ] + Dir.glob("lib/**/*")

  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0", "< 8.1"
end
