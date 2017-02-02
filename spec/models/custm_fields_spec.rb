require 'rails_helper'

RSpec.describe CustomFields do
  let(:key_id) { SecureRandom.uuid.tr('-', '_') }
  let(:alternative_key_id) { SecureRandom.uuid.tr('-', '_') }

  let(:test_class) do
    self.class.const_set(
      "A#{SecureRandom.uuid}".tr('-', ''),
      Class.new do
        include ActiveModel::Model
        attr_accessor :key_id, :custom
        include CustomFields
        setup_custom_field :key_id
      end,
    )
  end

  describe '#custom_class' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(key_id: 8).custom_instance }

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
    subject { test_class.new(key_id: 8, custom: custom).custom_instance }
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
    subject { test_class.new(key_id: 6) }
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

  describe 'validations' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(key_id: 6) }
    let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit', validations: validations } }) }

    describe 'presence' do
      let(:validations) { { presence: true } }

      it 'invalid when field is blank' do
        expect(subject.custom_instance).not_to be_valid
      end

      it 'valid when field is set' do
        subject.custom_instance = { fruit: 'apples' }
        expect(subject.custom_instance).to be_valid
      end

      it 'makes the base object invalid as well' do
        expect(subject).not_to be_valid
      end

      it 'puts error on the base class' do
        subject.valid?
        expect(subject.errors.full_messages).to eq(['Custom instance is invalid'])
      end
    end
  end

  describe 'types of fields' do
    before do
      expect(CustomConfig).to receive(:find_by).and_return(config)
    end
    subject { test_class.new(key_id: 6) }

    context 'number' do
      let(:config) { build(:custom_config, config: { fruit: { name: 'Fruit', type: 'number' } }) }

      it 'automatically adds a numerically validator' do
        subject.custom_instance = { fruit: 'apples' }
        expect(subject.custom_instance).not_to be_valid

        subject.custom_instance = { fruit: 10 }
        expect(subject.custom_instance).to be_valid
      end
    end
  end
end
