RSpec.describe Kreds do
  describe "#fetch!" do
    subject { described_class.fetch!(*args) }

    # Dummy credentials structure:
    # {
    #   :foo => {
    #     :bar => {
    #       :baz => 42
    #     }
    #   },
    #   :bad => nil
    # }

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
