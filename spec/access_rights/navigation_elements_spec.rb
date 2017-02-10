require 'rails_helper'

RSpec.describe Nav do
  let(:business) { create(:business) }
  let(:page_class) do
    # page is a controller instance so need to provide a heap of methods for the build to work
    Class.new do
      def current_user; end

      def current_page?(*); end

      def method_missing(*); end # rubocop:disable Style/MethodMissing

      def respond_to_missing?(m, *)
        m =~ /path$/ || super
      end

      def policy(obj)
        Pundit.policy(current_user, obj)
      end
    end
  end
  let(:page) do
    page_class.new.tap do |page|
      allow(page).to receive(:current_user).and_return(user)
    end
  end
  let(:user) { double(:user, business_id: business.id, role: role) }
  subject { tree(described_class.nav(page)) }

  context 'when user has all permissions' do
    let(:role) { create(:role, name: Role::SUPER_ADMIN) }

    it 'can see full navigation menu' do
      expect(subject).to eq(['Business', "Portfolio's", { 'Securities' => ['Add'] }, 'Configure'])
    end

    context 'and portfolios and securities exist' do
      let!(:portfolio) { create(:portfolio, name: 'Nav portfolio', business: business) }
      let!(:security) { create(:security, name: 'Nav security', business: business) }

      it 'can see full navigation menu' do
        expect(subject).to eq(
          [
            'Business',
            { "Portfolio's" => ['Nav portfolio'] },
            { 'Securities' => ['Add', 'Nav security'] },
            'Configure',
          ],
        )
      end
    end
  end

  context 'when user does not have `configure_system` permission' do
    let(:role) { create(:role, name: 'other') }

    it 'excludes the configuration link' do
      expect(subject).not_to include('Configure')
    end
  end

  context 'when user does not have `follow_security` permission' do
    let(:role) { create(:role, name: 'other') }

    it 'excludes the configuration link' do
      expect(subject[subject.index('Securities')]).not_to include('Add')
    end
  end

  def tree(nodes)
    nodes.map do |node|
      node.children.any? ? { node.name => tree(node.children) } : node.name
    end
  end
end
