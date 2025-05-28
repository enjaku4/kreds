# Kreds

[![Gem Version](https://badge.fury.io/rb/kreds.svg)](http://badge.fury.io/rb/kreds)
[![Github Actions badge](https://github.com/brownboxdev/kreds/actions/workflows/ci.yml/badge.svg)](https://github.com/brownboxdev/kreds/actions/workflows/ci.yml)

Kreds is a simpler, shorter, and safer way to access Rails credentials, with a few extra features built in. Rails credentials are a convenient way to store secrets, but retrieving them could be more intuitive — that's where Kreds comes in.

Instead of writing:
```ruby
Rails.application.credentials[:recaptcha][:site_key]
```

You can simply use:
```ruby
Kreds.fetch!(:recaptcha, :site_key)
```

This not only shortens your code but also ensures an exception is raised if a key is missing or a value is blank — with a clear, human-readable error message.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "kreds"
```

And then execute:
```bash
bundle install
```

## API Reference

### Core Methods

- `Kreds.fetch!(*keys, var: nil, &block)`

  Fetches credentials from the Rails credentials store.

  **Parameters:**
  - `*keys` - Variable number of symbols representing the key path
  - `var` - Optional environment variable name as fallback
  - `&block` - Optional block to execute if fetch fails

  **Returns:** The credential value

  **Raises:**
  - `Kreds::UnknownCredentialsError` - if the key path doesn’t exist
  - `Kreds::BlankCredentialsError` - if the value exists but is blank

  **Examples:**
  ```ruby
  # Basic usage
  Kreds.fetch!(:aws, :s3, :credentials, :access_key_id)

  # With environment variable fallback
  Kreds.fetch!(:aws, :access_key_id, var: "AWS_ACCESS_KEY_ID")

  # With custom error handling
  Kreds.fetch!(:api_key) do
    raise MyCustomError, "API key not configured"
  end
  ```

- `Kreds.env_fetch!(*keys, var: nil, &block)`

  Fetches credentials scoped by the current Rails environment (e.g., `:production`, `:staging`, `:development`).

  **Parameters:** Same as `fetch!`

  **Returns:** The credential value from `Rails.application.credentials[Rails.env]` followed by the provided key path

  **Raises:** Same exceptions as `fetch!`

  **Examples:**
  ```ruby
  # Looks in credentials[:production][:recaptcha][:site_key] in production
  Kreds.env_fetch!(:recaptcha, :site_key)

  # With fallback
  Kreds.env_fetch!(:recaptcha, :site_key, var: "RECAPTCHA_SITE_KEY")
  ```

- `Kreds.var!(name, &block)`

  Fetches a value directly from environment variables.

  **Parameters:**
  - `name` - Environment variable name (string)
  - `&block` - Optional block to execute if variable is missing/blank

  **Returns:** The environment variable value

  **Raises:**
  - `Kreds::UnknownEnvironmentVariableError` - if the variable doesn't exist
  - `Kreds::BlankEnvironmentVariableError` - if the variable exists but is blank

  **Example:**
  ```ruby
  Kreds.var!("AWS_ACCESS_KEY_ID")

  # With default value
  Kreds.var!("THREADS") { 1 }
  ```

### Utility Methods

- `Kreds.show`

  **Returns:** All credentials as a hash. Useful for debugging or working in the Rails console.

- `Kreds.key?(*keys)`

  Checks if a key path exists in credentials.

  **Returns:** Boolean

- `Kreds.env_key?(*keys)`

  Checks if a key path exists in environment-scoped credentials.

  **Returns:** Boolean

- `Kreds.var?(name)`

  Checks if an environment variable is set.

  **Returns:** Boolean

## Contributing

### Getting Help
- **Open a Discussion:** If you have a question, experience difficulties using the gem, or have a suggestion for improvements, feel free to use the Discussions section.

### Reporting Bugs
- **Create an Issue:** If you've identified a bug, please create an issue. Be sure to provide detailed information about the problem, including the steps to reproduce it.
- **Contribute a Solution:** Found a fix for the issue? Feel free to create a pull request with your changes.

Before creating an issue or a pull request, please read the [contributing guidelines](https://github.com/brownboxdev/kreds/blob/master/CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/brownboxdev/kreds/blob/master/LICENSE.txt).

## Code of Conduct

Everyone interacting in the Kreds project is expected to follow the [code of conduct](https://github.com/brownboxdev/kreds/blob/master/CODE_OF_CONDUCT.md).
