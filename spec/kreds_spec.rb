RSpec.describe Kreds do
  describe ".show" do
    it "returns the credentials structure" do
      expect(described_class.show).to eq(
        {
          foo: {
            bar: {
              baz: 42
            }
          },
          bad: nil,
          secret_key_base: "dummy_secret_key_base",
          test: {
            foo: [1, 2, 3]
          }
        }
      )
    end
  end

  describe ".fetch!" do
    describe "input validation" do
      subject { described_class.fetch!(*args, var:) }

      context "when no keys are provided" do
        let(:args) { [] }
        let(:var) { nil }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "No keys provided")
        end
      end

      context "when keys are not symbols or strings" do
        let(:args) { [:foo, 42] }
        let(:var) { nil }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Credentials Key must be a Symbol or a String")
        end
      end

      context "when var is not a string" do
        let(:args) { [:foo, :bar, :baz] }
        let(:var) { 42 }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Environment variable must be a String")
        end
      end
    end

    context "when var is not provided" do
      subject { described_class.fetch!(*args) }

      context "when symbol keys exist and the value is in place" do
        let(:args) { [:foo, :bar, :baz] }

        it { is_expected.to eq(42) }
      end

      context "when string keys exist and the value is in place" do
        let(:args) { ["foo", "bar", "baz"] }

        it { is_expected.to eq(42) }
      end

      context "when a key is missing" do
        let(:args) { [:foo, :bar, :bad] }

        it "is raises error" do
          expect { subject }.to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bar][:bad]")
        end
      end

      context "when a key in the middle is missing" do
        let(:args) { [:foo, :bad, :baz] }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bad]")
        end
      end

      context "when the value is blank" do
        let(:args) { [:bad] }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::BlankCredentialsError, "Blank value in credentials: [:bad]")
        end
      end

      context "when there are too many keys" do
        let(:args) { [:foo, :bar, :baz, :bad] }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:foo][:bar][:baz][:bad]")
        end
      end
    end

    context "when var is provided" do
      subject { described_class.fetch!(*args, var:) }

      context "when the environment variable exists and the value is in place" do
        let(:var) { "RAILS_ENV" }

        context "when the credential are in place" do
          let(:args) { [:foo, :bar, :baz] }

          it { is_expected.to eq(42) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it { is_expected.to eq("test") }
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it { is_expected.to eq("test") }
        end
      end

      context "when the environment variable is missing" do
        let(:var) { "MISSING_ENV_VAR" }

        context "when credentials are in place" do
          let(:args) { [:foo, :bar, :baz] }

          it { is_expected.to eq(42) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Blank value in credentials: [:bad], Environment variable not found: \"MISSING_ENV_VAR\"")
          end
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:foo][:bar][:bad], Environment variable not found: \"MISSING_ENV_VAR\"")
          end
        end
      end

      context "when the environment variable value is blank" do
        let(:var) { "BLANK_ENV_VAR" }

        before { ENV["BLANK_ENV_VAR"] = "" }
        after { ENV.delete("BLANK_ENV_VAR") }

        context "when credentials are in place" do
          let(:args) { [:foo, :bar, :baz] }

          it { is_expected.to eq(42) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Blank value in credentials: [:bad], Blank value in environment variable: \"BLANK_ENV_VAR\"")
          end
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:foo][:bar][:bad], Blank value in environment variable: \"BLANK_ENV_VAR\"")
          end
        end
      end
    end

    context "when the block is given" do
      let(:args) { [:no_such_key] }
      let(:var) { "MISSING_ENV_VAR" }

      it "returns the block value" do
        expect(described_class.fetch!(*args, var:) { "default_value" }).to eq("default_value")
      end
    end
  end

  describe ".env_fetch!" do
    describe "input validation" do
      subject { described_class.env_fetch!(*args, var:) }

      context "when keys are not symbols or strings" do
        let(:args) { [:foo, 42] }
        let(:var) { nil }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Credentials Key must be a Symbol or a String")
        end
      end

      context "when var is not a string" do
        let(:args) { [:foo, :bar, :baz] }
        let(:var) { 42 }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Environment variable must be a String")
        end
      end
    end

    context "when no var is provided" do
      subject { described_class.env_fetch!(*args) }

      context "when no keys are provided" do
        let(:args) { [] }

        it { is_expected.to eq({ foo: [1, 2, 3] }) }
      end

      context "when keys exist and the value is in place" do
        let(:args) { [:foo] }

        it { is_expected.to eq([1, 2, 3]) }
      end

      context "when a key is missing" do
        let(:args) { [:foo, :bar, :bad] }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::UnknownCredentialsError, "Credentials key not found: [:test][:foo][:bar]")
        end
      end
    end

    context "when var is provided" do
      subject { described_class.env_fetch!(*args, var:) }

      context "when the environment variable exists and the value is in place" do
        let(:var) { "RAILS_ENV" }

        context "when the credential are in place" do
          let(:args) { [:foo] }

          it { is_expected.to eq([1, 2, 3]) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it { is_expected.to eq("test") }
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it { is_expected.to eq("test") }
        end
      end

      context "when the environment variable is missing" do
        let(:var) { "MISSING_ENV_VAR" }

        context "when credentials are in place" do
          let(:args) { [:foo] }

          it { is_expected.to eq([1, 2, 3]) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:test][:bad], Environment variable not found: \"MISSING_ENV_VAR\"")
          end
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:test][:foo][:bar], Environment variable not found: \"MISSING_ENV_VAR\"")
          end
        end
      end

      context "when the environment variable value is blank" do
        let(:var) { "BLANK_ENV_VAR" }

        before { ENV["BLANK_ENV_VAR"] = "" }
        after { ENV.delete("BLANK_ENV_VAR") }

        context "when credentials are in place" do
          let(:args) { [:foo] }

          it { is_expected.to eq([1, 2, 3]) }
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it "raises error" do
            expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:test][:bad], Blank value in environment variable: \"BLANK_ENV_VAR\"")
          end
        end
      end
    end

    context "with block" do
      it "returns the value from block" do
        expect(described_class.env_fetch!(:no_such_key, var: "MY_VAR") { "default_value" }).to eq("default_value")
      end
    end
  end

  describe ".var!" do
    subject { described_class.var!(var) }

    context "when var is not a string" do
      let(:var) { 42 }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Environment variable must be a String")
      end
    end

    context "when the environment variable exists and the value is in place" do
      let(:var) { "RAILS_ENV" }

      it { is_expected.to eq("test") }
    end

    context "when the environment variable is missing" do
      let(:var) { "MISSING_ENV_VAR" }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::UnknownEnvironmentVariableError, "Environment variable not found: \"MISSING_ENV_VAR\"")
      end
    end

    context "when the environment variable value is blank" do
      let(:var) { "BLANK_ENV_VAR" }

      before { ENV["BLANK_ENV_VAR"] = "" }
      after { ENV.delete("BLANK_ENV_VAR") }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::BlankEnvironmentVariableError, "Blank value in environment variable: \"BLANK_ENV_VAR\"")
      end
    end

    context "when the block is given" do
      let(:var) { "MISSING_ENV_VAR" }

      it "returns the block value" do
        expect(described_class.var!(var) { "default_value" }).to eq("default_value")
      end
    end
  end

  describe ".key?" do
    subject { described_class.key?(*args) }

    context "when no keys are provided" do
      let(:args) { [] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::InvalidArgumentError, "No keys provided")
      end
    end

    context "when keys are not symbols or strings" do
      let(:args) { [:foo, 42] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Credentials Key must be a Symbol or a String")
      end
    end

    context "when the key exists" do
      context "with symbol keys" do
        let(:args) { [:foo, :bar, :baz] }

        it { is_expected.to be true }
      end

      context "with string keys" do
        let(:args) { ["foo", "bar", "baz"] }

        it { is_expected.to be true }
      end
    end

    context "when the key does not exist" do
      let(:args) { [:foo, :bar, :bad] }

      it { is_expected.to be false }
    end

    context "when there are too many keys" do
      let(:args) { [:foo, :bar, :baz, :bad] }

      it { is_expected.to be false }
    end
  end

  describe ".env_key?" do
    subject { described_class.env_key?(*args) }

    context "when no keys are provided" do
      let(:args) { [] }

      it { is_expected.to be true }
    end

    context "when keys are not symbols or strings" do
      let(:args) { [:foo, 42] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Credentials Key must be a Symbol or a String")
      end
    end

    context "when the key exists" do
      context "with symbol keys" do
        let(:args) { [:foo] }

        it { is_expected.to be true }
      end

      context "with string keys" do
        let(:args) { ["foo"] }

        it { is_expected.to be true }
      end
    end

    context "when the key does not exist" do
      let(:args) { [:foo, :bad] }

      it { is_expected.to be false }
    end

    context "when there are too many keys" do
      let(:args) { [:foo, :bar, :baz, :bad] }

      it { is_expected.to be false }
    end
  end

  describe ".var?" do
    subject { described_class.var?(var) }

    context "when var is not a string" do
      let(:var) { 42 }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Environment variable must be a String")
      end
    end

    context "when the environment variable exists" do
      let(:var) { "RAILS_ENV" }

      it { is_expected.to be true }
    end

    context "when the environment variable is missing" do
      let(:var) { "MISSING_ENV_VAR" }

      it { is_expected.to be false }
    end
  end
end
