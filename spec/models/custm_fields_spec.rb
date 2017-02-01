require 'rails_helper'

RSpec.describe CustomFields do
  let(:key_id) { SecureRandom.uuid.tr('-', '_') }
  let(:alternative_key_id) { SecureRandom.uuid.tr('-', '_') }

  let(:test_class) do
    Class.new(Struct.new(:key_id, :custom)) do
      include CustomFields
      setup_custom_field :key_id
    end
  end

  describe '#custom_class' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(8).custom_instance }

    context 'when no configuration is provided' do
      let(:config) { nil }

      it 'uses the base class' do
        expect(test_class.custom_class(10)).to eq(CustomFields::CustomField)
      end
    end

    context 'when configuration does exist' do
      let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit' } }) }

      it 'uses a custom class' do
        expect(test_class.custom_class(10)).not_to eq(CustomFields::CustomField)
      end

      it 'returns the same object for the same key ID' do
        expect(test_class.custom_class(10)).to eq(test_class.custom_class(10))
      end
    end
  end

  describe '#custom_instance' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(8, custom).custom_instance }
    let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit' } }) }
    let(:custom) { nil }

    it 'create an instance of the custom_class' do
      expect(subject).to be_a(test_class.custom_class(8))
    end

    it 'makes reader methods for each of the fields in the config' do
      expect { subject.fruit }.not_to raise_error
    end

    it 'initializes the reader to nil by default' do
      expect(subject.fruit).to be_nil
    end

    context 'when custom data already exists' do
      let(:custom) { { fruit: 'apples' } }

      it 'set the value of the reader' do
        expect(subject.fruit).to eq('apples')
      end
    end

    it 'custom fields have a private writer method - object should be immutable' do
      expect { subject.fruit = 'banana' }.to raise_error(NoMethodError)
    end

    context 'when the field has a default value' do
      let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit', default: 'pears' } }) }

      it 'initializes with the default' do
        expect(subject.fruit).to eq('pears')
      end
    end

    it 'can be converted back into a hash/json format' do
      expect(subject.as_json).to eq('fruit' => nil)
    end
  end

  describe '#custom_instance=' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(8) }
    let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit' } }) }

    it 'will only accepts know fields' do
      expect { subject.custom_instance = { animals: 'bears' } }.to raise_error(ActiveModel::UnknownAttributeError)
    end

    it 'writes know fields to the custom field when using symbol keys' do
      subject.custom_instance = { fruit: 'melon' }
      expect(subject.custom).to eq('fruit' => 'melon')
    end

    it 'writes know fields to the custom field when using text keys' do
      subject.custom_instance = { 'fruit' => 'melon' }
      expect(subject.custom).to eq('fruit' => 'melon')
    end
  end
end
