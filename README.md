# Kreds: Streamlined Rails Credentials Access

[![Gem Version](https://badge.fury.io/rb/kreds.svg)](http://badge.fury.io/rb/kreds)
[![Github Actions badge](https://github.com/brownboxdev/kreds/actions/workflows/ci.yml/badge.svg)](https://github.com/brownboxdev/kreds/actions/workflows/ci.yml)

Kreds is a simpler, shorter, and safer way to access Rails credentials, with a few extra features built in. Rails credentials are a convenient way to store secrets, but retrieving them could be more intuitive — that's where Kreds comes in.

**Key Features:**

- Simplified credential access with clear error messages
- Environment variable fallback support
- Environment-scoped credentials access
- Blank value detection and prevention

**Before and After:**

```ruby
# Instead of this (long, silent failures if value is missing):
Rails.application.credentials[:recaptcha][:site_key]
# => nil

# Or this (long, unclear errors):
Rails.application.credentials[:captcha][:site_key]
# => undefined method `[]' for nil:NilClass (NoMethodError)

# Or even this (longer, still unclear errors):
Rails.application.credentials.fetch(:recaptcha).fetch(:key)
# => key not found: :key (KeyError)

# You can write this (shorter, human-readable errors):
Kreds.fetch!(:recaptcha, :site_key)
# => Blank value in credentials: [:recaptcha][:site_key] (Kreds::BlankCredentialsError)
Kreds.fetch!(:captcha, :site_key)
# => Credentials key not found: [:captcha] (Kreds::UnknownCredentialsError)
```

## Table of Contents

**Gem Usage:**
  - [Installation](#installation)
  - [Credential Fetching](#credential-fetching)
  - [Environment-Scoped Credentials](#environment-scoped-credentials)
  - [Environment Variables](#environment-variables)
  - [Debug and Inspection](#debug-and-inspection)

**Community Resources:**
  - [Getting Help and Contributing](#getting-help-and-contributing)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

## Installation

Add Kreds to your Gemfile:

```ruby
gem "kreds"
```

And then execute:

```bash
bundle install
```

## Credential Fetching

**`Kreds.fetch!(*keys, var: nil, &block)`**

Fetches credentials from the Rails credentials store.

**Parameters:**
- `*keys` - Variable number of symbols representing the key path
- `var` - Optional environment variable name as fallback
- `&block` - Optional block to execute if fetch fails

**Returns:** The credential value

**Raises:**
- `Kreds::UnknownCredentialsError` - if the key path doesn't exist
- `Kreds::BlankCredentialsError` - if the value exists but is blank

```ruby
# Basic usage
Kreds.fetch!(:aws, :s3, :credentials, :access_key_id)

# With environment variable fallback
Kreds.fetch!(:aws, :access_key_id, var: "AWS_ACCESS_KEY_ID")

# With block
Kreds.fetch!(:api_key) do
  raise MyCustomError, "API key not configured"
end
```

## Environment-Scoped Credentials

**`Kreds.env_fetch!(*keys, var: nil, &block)`**

Fetches credentials scoped by the current Rails environment (e.g., `:production`, `:staging`, `:development`).

**Parameters:** Same as `fetch!`

**Returns:** The credential value from `Rails.application.credentials[Rails.env]` followed by the provided key path

**Raises:** Same exceptions as `fetch!`

```ruby
# Looks in credentials[:production][:recaptcha][:site_key] in production
Kreds.env_fetch!(:recaptcha, :site_key)
```

## Environment Variables

**`Kreds.var!(name, &block)`**

Fetches a value directly from environment variables.

**Parameters:**
- `name` - Environment variable name
- `&block` - Optional block to execute if variable is missing/blank

**Returns:** The environment variable value

**Raises:**
- `Kreds::UnknownEnvironmentVariableError` - if the variable doesn't exist
- `Kreds::BlankEnvironmentVariableError` - if the variable exists but is blank

```ruby
# Direct environment variable access
Kreds.var!("AWS_ACCESS_KEY_ID")

# With block
Kreds.var!("THREADS") { 1 }
```

## Debug and Inspection

**`Kreds.show`**

Useful for debugging and exploring available credentials in the Rails console.

**Returns:** Hash containing all credentials

```ruby
Kreds.show
# => { aws: { access_key_id: "...", secret_access_key: "..." }, ... }
```

## Getting Help and Contributing

### Getting Help
Have a question or need assistance? Open a discussion in our [discussions section](https://github.com/brownboxdev/kreds/discussions) for:
- Usage questions
- Implementation guidance
- Feature suggestions

### Reporting Issues
Found a bug? Please [create an issue](https://github.com/brownboxdev/kreds/issues) with:
- A clear description of the problem
- Steps to reproduce the issue
- Your environment details (Rails version, Ruby version, etc.)

### Contributing Code
Ready to contribute? You can:
- Fix bugs by submitting pull requests
- Improve documentation
- Add new features (please discuss first in our [discussions section](https://github.com/brownboxdev/kreds/discussions))

Before contributing, please read the [contributing guidelines](https://github.com/brownboxdev/kreds/blob/master/CONTRIBUTING.md)

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/brownboxdev/kreds/blob/master/LICENSE.txt).

## Code of Conduct

Everyone interacting in the Kreds project is expected to follow the [code of conduct](https://github.com/brownboxdev/kreds/blob/master/CODE_OF_CONDUCT.md).
