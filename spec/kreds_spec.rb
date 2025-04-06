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

      it "is raises UnknownKeyError error" do
        expect { subject }.to raise_error(Kreds::UnknownKeyError, "Key not found: [:foo][:bar][:bad]")
      end
    end

    context "when a key in the middle is missing" do
      let(:args) { [:foo, :bad, :baz] }

      it "raises UnknownKeyError error" do
        expect { subject }.to raise_error(Kreds::UnknownKeyError, "Key not found: [:foo][:bad]")
      end
    end

    context "when the value is blank" do
      let(:args) { [:bad] }

      it "raises BlankValueError error" do
        expect { subject }.to raise_error(Kreds::BlankValueError, "Blank value for: [:bad]")
      end
    end

    context "when there are too many keys" do
      let(:args) { [:foo, :bar, :baz, :bad] }

      it "raises UnknownKeyError error" do
        expect { subject }.to raise_error(Kreds::UnknownKeyError, "Key not found: [:foo][:bar][:baz][:bad]")
      end
    end
  end
end
