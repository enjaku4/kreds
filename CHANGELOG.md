## v1.1.2

- Added input validation using `dry-types` for user-facing API

## v1.1.1

- Updated gemspec metadata to include the correct homepage URL

## v1.1.0

- Added block support for fallback behavior in all fetching methods

## v1.0.0

- Dropped support for Rails 7.0
- Dropped support for Ruby 3.1
- Replaced `Kreds::BlankValueError` and `Kreds::UnknownKeyError` with `Kreds::BlankCredentialsError` and `Kreds::UnknownCredentialsError`, respectively
- Added optional fallback to environment variables for `Kreds.fetch!` method
- Added shortcut method `Kreds.var!` for fetching values directly from environment variables
- Added `Kreds.env_fetch!` method for fetching values from credentials per Rails environment
- Added `Kreds.show` method for displaying all credentials as a hash

## v0.1.0

- Initial release
