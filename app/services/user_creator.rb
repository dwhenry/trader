class UserCreator
  include ActiveModel::Model

  attr_accessor :current_user, :emails, :role_id

  validates :emails, presence: true
  validate do
    if emails.present?
      errors.add(:role_id, 'is not allowed') unless users.first.role.level <= current_user.role.level
      users.each do |user|
        errors.add(:emails, "#{user.email} #{user.errors.messages.values.flatten.to_sentence}") unless user.valid?
      end
    end
  end

  def users
    @users ||= emails.split(',').map(&:strip).uniq.map do |email|
      User.new(
        business: @current_user.business,
        email: email,
        role_id: @role_id,
      )
    end
  end

  def save
    valid? && users.each(&:save!)
  end
end
