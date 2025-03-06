RSpec.describe Kreds do
  describe "#fetch!" do
    subject { described_class.fetch!(*args) }

    before do
      allow(Rails.application).to receive(:credentials)
        .and_return({ foo: { bar: { baz: 42 } }, bad: "", qux: 13 })
    end

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

    context "when the value is blank" do
      let(:args) { [:bad] }

      it "raises BlankValueError error" do
        expect { subject }.to raise_error(Kreds::BlankValueError, "Blank value for: [:bad]")
      end
    end

    context "when there are too many keys" do
      let(:args) { [:qux, :foo] }

      it "raises UnknownKeyError error" do
        expect { subject }.to raise_error(Kreds::UnknownKeyError, "Key not found: [:qux][:foo]")
      end
    end
  end
end
