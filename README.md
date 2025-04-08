# Kreds

[![Gem Version](https://badge.fury.io/rb/kreds.svg)](http://badge.fury.io/rb/kreds)
[![Github Actions badge](https://github.com/enjaku4/kreds/actions/workflows/ci.yml/badge.svg)](https://github.com/enjaku4/kreds/actions/workflows/ci.yml)

Kreds is a simpler, shorter, and safer way to access Rails credentials, with a few additional features built in. Rails credentials are a convenient way to store secrets, but retrieving them could be more intuitive — that’s where Kreds comes in.

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

```shell
bundle install
```

## Usage

### Fetch from credentials

```ruby
Kreds.fetch!(:aws, :s3, :credentials, :access_key_id)
```

If you make a typo, such as writing `access_key` instead of `access_key_id`, Kreds will raise `Kreds::UnknownCredentialsError` with the message: `Credentials key not found: [:aws][:s3][:credentials][:access_key]`.

Similarly, if you add an extra key that doesn’t exist: `Kreds.fetch!(:aws, :s3, :credentials, :access_key_id, :id)`, Kreds will raise `Kreds::UnknownCredentialsError` with the message: `Credentials key not found: [:aws][:s3][:credentials][:access_key_id][:id]`.

If all keys are correct but the value is blank, Kreds will raise `Kreds::BlankCredentialsError` with the message: `Blank value in credentials: [:aws][:s3][:credentials][:access_key_id]`.

### Fallback to environment variables

You can optionally provide a fallback environment variable:

```ruby
Kreds.fetch!(:aws, :s3, :credentials, :access_key_id, var: "AWS_ACCESS_KEY_ID")
```

If the key is missing or blank in credentials, Kreds will attempt to fetch the value from the specified environment variable.

If both sources are missing or blank, a combined error is raised.

### Directly fetch from environment variable

You can also fetch directly from an environment variable:

```ruby
Kreds.var!("AWS_ACCESS_KEY_ID")
```

This raises `Kreds::UnknownEnvironmentVariableError` if the variable is missing, and `Kreds::BlankEnvironmentVariableError` if it is present but the value is blank.

### Fetch per Rails environment

If your credentials are scoped by Rails environment (e.g., `:production`, `:staging`, `:development`), you can fetch keys under the current environment using:

```ruby
Kreds.env_fetch!(:recaptcha, :site_key)
```

This will look for the key in `Rails.application.credentials[Rails.env]`. For example, in the `production` environment, it will look for `Rails.application.credentials[:production][:recaptcha][:site_key]`, and raise the same errors if the key is missing or the value is blank.

You can also provide an optional fallback environment variable:

```ruby
Kreds.env_fetch!(:recaptcha, :site_key, var: "RECAPTCHA_SITE_KEY")
```

### Show credentials

To inspect all credentials as a hash:

```ruby
Kreds.show
```

Useful for debugging or working in the Rails console.

## Problems?

Facing a problem or want to suggest an enhancement?

- **Open a Discussion**: If you have a question, experience difficulties using the gem, or have a suggestion for improvements, feel free to use the Discussions section.

Encountered a bug?

- **Create an Issue**: If you've identified a bug, please create an issue. Be sure to provide detailed information about the problem, including the steps to reproduce it.
- **Contribute a Solution**: Found a fix for the issue? Feel free to create a pull request with your changes.

## Contributing

Before creating an issue or a pull request, please read the [contributing guidelines](https://github.com/enjaku4/kreds/blob/master/CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/enjaku4/kreds/blob/master/LICENSE.txt).

## Code of Conduct

Everyone interacting in the Kreds project is expected to follow the [code of conduct](https://github.com/enjaku4/kreds/blob/master/CODE_OF_CONDUCT.md).
