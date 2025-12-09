require_relative "lib/kreds/version"

Gem::Specification.new do |spec|
  spec.name = "kreds"
  spec.version = Kreds::VERSION
  spec.authors = ["enjaku4"]
  spec.email = ["contact@brownbox.dev"]
  spec.homepage = "https://github.com/enjaku4/kreds"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata["mailing_list_uri"] = "#{spec.homepage}/discussions"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.summary = "The missing shorthand for Rails credentials"
  spec.description = "Simpler and safer Rails credentials access with blank value detection and clear error messages"
  spec.license = "MIT"
  # TODO: support new ruby
  spec.required_ruby_version = ">= 3.2", "< 4.1"

  spec.files = [
    "kreds.gemspec", "README.md", "CHANGELOG.md", "LICENSE.txt"
  ] + Dir.glob("lib/**/*")

  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "rails", ">= 7.1", "< 8.2"
end
