RSpec.describe Kreds do
  describe ".show" do
    let(:credentials) do
      {
        foo: { bar: { baz: 42 } },
        bad: nil,
        secret_key_base: "dummy_secret_key_base",
        test: { foo: [1, 2, 3] }
      }
    end

    it "returns the credentials structure" do
      expect(described_class.show).to eq(credentials)
    end
  end

  describe ".fetch!" do
    describe "input validation" do
      it "raises error for empty keys" do
        expect { described_class.fetch! }
          .to raise_error(Kreds::InvalidArgumentError, "Expected an array of symbols or strings, got `[]`")
      end

      it "raises error for invalid key types" do
        expect { described_class.fetch!(:foo, 42) }
          .to raise_error(Kreds::InvalidArgumentError, "Expected an array of symbols or strings, got `[:foo, 42]`")
      end
    end

    context "without environment variable fallback" do
      it "returns value for symbol keys" do
        expect(described_class.fetch!(:foo, :bar, :baz)).to eq(42)
      end

      it "returns value for string keys" do
        expect(described_class.fetch!("foo", "bar", "baz")).to eq(42)
      end

      it "raises error for missing end key" do
        expect { described_class.fetch!(:foo, :bar, :bad) }
          .to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bar][:bad]")
      end

      it "raises error for missing middle key" do
        expect { described_class.fetch!(:foo, :bad, :baz) }
          .to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bad]")
      end

      it "raises error for blank value" do
        expect { described_class.fetch!(:bad) }
          .to raise_error(Kreds::BlankCredentialsError, "Blank value in credentials: [:bad]")
      end
    end

    context "with environment variable fallback" do
      it "raises error for invalid var type when fallback is needed" do
        expect { described_class.fetch!(:bad, var: 42) }
          .to raise_error(Kreds::InvalidArgumentError, "Expected a non-empty string, got `42`")
      end

      context "when env var exists" do
        it "returns credentials when available" do
          expect(described_class.fetch!(:foo, :bar, :baz, var: "RAILS_ENV")).to eq(42)
        end

        it "returns env var when credentials blank" do
          expect(described_class.fetch!(:bad, var: "RAILS_ENV")).to eq("test")
        end

        it "returns env var when credentials missing" do
          expect(described_class.fetch!(:foo, :bar, :bad, var: "RAILS_ENV")).to eq("test")
        end
      end

      context "when env var missing" do
        it "returns credentials when available" do
          expect(described_class.fetch!(:foo, :bar, :baz, var: "MISSING_VAR")).to eq(42)
        end

        it "raises combined error for blank credentials" do
          expect { described_class.fetch!(:bad, var: "MISSING_VAR") }
            .to raise_error(Kreds::Error, /Blank value in credentials.*Environment variable not found/)
        end

        it "raises combined error for missing credentials" do
          expect { described_class.fetch!(:foo, :bar, :bad, var: "MISSING_VAR") }
            .to raise_error(Kreds::Error, /Credentials key not found.*Environment variable not found/)
        end
      end

      context "when env var blank" do
        around do |example|
          ENV["BLANK_VAR"] = ""
          example.run
          ENV.delete("BLANK_VAR")
        end

        it "returns credentials when available" do
          expect(described_class.fetch!(:foo, :bar, :baz, var: "BLANK_VAR")).to eq(42)
        end

        it "raises combined error for blank credentials" do
          expect { described_class.fetch!(:bad, var: "BLANK_VAR") }
            .to raise_error(Kreds::Error, /Blank value in credentials.*Blank value in environment variable/)
        end
      end
    end

    context "with block" do
      it "returns block value when both credentials and env var fail" do
        result = described_class.fetch!(:missing, var: "MISSING_VAR") { "default" }
        expect(result).to eq("default")
      end
    end

    context "when handling edge cases" do
      it "raises error when trying to access non-hash as hash" do
        expect { described_class.fetch!(:foo, :bar, :baz, :extra) }
          .to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bar][:baz][:extra]")
      end

      it "works with single key" do
        expect(described_class.fetch!(:foo)).to eq({ bar: { baz: 42 } })
      end
    end
  end

  describe ".env_fetch!" do
    it "raises error for invalid key types" do
      expect { described_class.env_fetch!(:foo, 42) }
        .to raise_error(Kreds::InvalidArgumentError, "Expected an array of symbols or strings, got `[\"test\", :foo, 42]`")
    end

    it "raises error for invalid var type when fallback is needed" do
      expect { described_class.env_fetch!(:bad, var: 42) }
        .to raise_error(Kreds::InvalidArgumentError, "Expected a non-empty string, got `42`")
    end

    context "without var" do
      it "returns entire test environment hash when no keys provided" do
        expect(described_class.env_fetch!).to eq({ foo: [1, 2, 3] })
      end

      it "returns specific value from test environment" do
        expect(described_class.env_fetch!(:foo)).to eq([1, 2, 3])
      end

      it "raises error for missing key in test environment" do
        expect { described_class.env_fetch!(:foo, :bar, :bad) }
          .to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:test][:foo][:bar]")
      end
    end

    context "with var" do
      it "works like regular fetch! with environment prefix" do
        expect(described_class.env_fetch!(:foo, var: "RAILS_ENV")).to eq([1, 2, 3])
      end

      it "falls back to env var when credentials missing" do
        expect(described_class.env_fetch!(:missing, var: "RAILS_ENV")).to eq("test")
      end
    end

    context "with block" do
      it "returns block value when both fail" do
        result = described_class.env_fetch!(:missing, var: "MISSING_VAR") { "default" }
        expect(result).to eq("default")
      end
    end
  end

  describe ".var!" do
    it "raises error for nil var" do
      expect { described_class.var!(nil) }.to raise_error(Kreds::InvalidArgumentError, "Expected a non-empty string, got `nil`")
    end

    it "raises error for non-string var" do
      expect { described_class.var!(42) }.to raise_error(Kreds::InvalidArgumentError, "Expected a non-empty string, got `42`")
    end

    it "returns environment variable value" do
      expect(described_class.var!("RAILS_ENV")).to eq("test")
    end

    it "raises error for missing variable" do
      expect { described_class.var!("MISSING_VAR") }
        .to raise_error(Kreds::UnknownEnvironmentVariableError, /Environment variable not found/)
    end

    it "raises error for blank variable" do
      ENV["BLANK_VAR"] = ""
      expect { described_class.var!("BLANK_VAR") }
        .to raise_error(Kreds::BlankEnvironmentVariableError, /Blank value in environment variable/)
      ENV.delete("BLANK_VAR")
    end

    context "with block" do
      it "returns block value for missing variable" do
        result = described_class.var!("MISSING_VAR") { "default" }
        expect(result).to eq("default")
      end
    end
  end
end
