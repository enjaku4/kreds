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
    context "when var is not provided" do
      subject { described_class.fetch!(*args) }

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

      context "when keys exist and the value is in place" do
        let(:args) { [:foo, :bar, :baz] }

        it "returns the value" do
          expect(subject).to eq(42)
        end
      end

      context "when keys exist and the value is in place with a string" do
        let(:args) { ["foo", "bar", "baz"] }

        it "returns the value" do
          expect(subject).to eq(42)
        end
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

    context "when the var is provided" do
      subject { described_class.fetch!(*args, var:) }

      context "when var is not a string" do
        let(:args) { [:foo, :bar, :baz] }
        let(:var) { 42 }

        it "raises error" do
          expect { subject }.to raise_error(Kreds::InvalidArgumentError, "Environment variable must be a String")
        end
      end

      context "when the environment variable exists and the value is in place" do
        let(:var) { "RAILS_ENV" }

        context "when the credential are in place" do
          let(:args) { [:foo, :bar, :baz] }

          it "returns the credential value" do
            expect(subject).to eq(42)
          end
        end

        context "when the credential is blank" do
          let(:args) { [:bad] }

          it "returns the environment variable value" do
            expect(subject).to eq("test")
          end
        end

        context "when the credential is missing" do
          let(:args) { [:foo, :bar, :bad] }

          it "returns the environment variable value" do
            expect(subject).to eq("test")
          end
        end
      end

      context "when the environment variable is missing" do
        let(:var) { "MISSING_ENV_VAR" }

        context "when credentials are in place" do
          let(:args) { [:foo, :bar, :baz] }

          it "returns the credential value" do
            expect(subject).to eq(42)
          end
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

          it "returns the credential value" do
            expect(subject).to eq(42)
          end
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
  end

  describe ".env_fetch!" do
    context "with stubbed data" do
      let(:result) { double }

      before { allow(described_class).to receive(:fetch!).with("test", :foo, var: "MY_VAR").and_return(result) }

      it "calls fetch! with Rails.env" do
        expect(described_class.env_fetch!(:foo, var: "MY_VAR")).to eq(result)
      end
    end

    context "with real data" do
      it "returns the value from credentials" do
        expect(described_class.env_fetch!(:foo)).to eq([1, 2, 3])
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

      it "returns the value" do
        expect(subject).to eq("test")
      end
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
  end
end
