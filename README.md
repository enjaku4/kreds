<!-- TODO: description of the new methods -->

# Kreds

[![Gem Version](https://badge.fury.io/rb/kreds.svg)](http://badge.fury.io/rb/kreds)
[![Github Actions badge](https://github.com/enjaku4/kreds/actions/workflows/ci.yml/badge.svg)](https://github.com/enjaku4/kreds/actions/workflows/ci.yml)

Kreds is a simpler and shorter way to access Rails credentials — with safety built in. Rails credentials are a convenient way to store secrets, but retrieving them could be more intuitive. That’s where Kreds comes in.

Instead of writing:

```ruby
Rails.application.credentials[:recaptcha][:site_key]
```

You can simply use:

```ruby
Kreds.fetch!(:recaptcha, :site_key)
```

This not only shortens your code but also ensures an exception is raised if a key is missing or a value is blank, with a clear, human-readable error message.

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

Kreds provides a single method `.fetch!(*keys)`:

```ruby
Kreds.fetch!(:aws, :s3, :credentials, :access_key_id)
```

If you make a typo, such as writing `access_key` instead of `access_key_id`, Kreds will raise `Kreds::UnknownKeyError` with the message: `Key not found: [:aws][:s3][:credentials][:access_key]`. The same applies to any incorrect key in the path.

Similarly, if you add an extra key that doesn’t exist, such as: `Kreds.fetch!(:aws, :s3, :credentials, :access_key_id, :id)`, Kreds will raise `Kreds::UnknownKeyError` with the message: `Key not found: [:aws][:s3][:credentials][:access_key_id][:id]`.

Kreds also ensures that values are not left blank. For example, if all keys are correct but the value for `access_key_id` is empty, Kreds will raise `Kreds::BlankValueError` with the message: `Blank value for: [:aws][:s3][:credentials][:access_key_id]`.

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
