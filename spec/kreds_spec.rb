RSpec.describe Kreds do
  # Dummy credentials structure:
  # {
  #   foo: {
  #     bar: {
  #       baz: 42
  #     }
  #   },
  #   bad: nil,
  #   :secret_key_base: "dummy_secret_key_base"
  # }

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
          secret_key_base: "dummy_secret_key_base"
        }
      )
    end
  end

  describe ".fetch!" do
    subject { described_class.fetch!(*args) }

    context "when keys exist and the value is in place" do
      let(:args) { [:foo, :bar, :baz] }

      it "returns the value" do
        expect(subject).to eq(42)
      end
    end

    context "when a key is missing" do
      let(:args) { [:foo, :bar, :bad] }

      it "is raises error" do
        expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:foo][:bar][:bad]")
      end
    end

    context "when a key in the middle is missing" do
      let(:args) { [:foo, :bad, :baz] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:foo][:bad]")
      end
    end

    context "when the value is blank" do
      let(:args) { [:bad] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::Error, "Blank value in credentials: [:bad]")
      end
    end

    context "when there are too many keys" do
      let(:args) { [:foo, :bar, :baz, :bad] }

      it "raises error" do
        expect { subject }.to raise_error(Kreds::Error, "Credentials key not found: [:foo][:bar][:baz][:bad]")
      end
    end
  end

  describe ".var!" do
    subject { described_class.var!(var) }

    context "when the environment variable exists and the value is in place" do
      let(:var) { "RAILS_ENV" }

      it "returns the value" do
        expect(subject).to eq("test")
      end
    end

    context "when the environment variable is missing" do
      let(:var) { "MISSING_ENV_VAR" }

      it "raises error" do
        expect { subject }.to raise_error(
          Kreds::Error, "Environment variable not found: \"MISSING_ENV_VAR\""
        )
      end
    end

    context "when the environment variable value is blank" do
      let(:var) { "BLANK_ENV_VAR" }

      before { ENV["BLANK_ENV_VAR"] = "" }
      after { ENV.delete("BLANK_ENV_VAR") }

      it "raises error" do
        expect { subject }.to raise_error(
          Kreds::Error, "Blank value in environment variable: \"BLANK_ENV_VAR\""
        )
      end
    end
  end
end
