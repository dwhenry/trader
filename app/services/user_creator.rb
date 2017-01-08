class UserCreator
  def initialize(current_user, emails, role)
    @current_user = current_user
    @emails = emails.split(',').map(&:strip).uniq
    @role = role
  end

  def valid?
    @emails.all? do |email|
      User.find_by(email: email).nil? &&
        User.new(email: email).valid?
    end
  end

  def save
    return false unless valid?
    @emails.each do |email|
      User.create!(
        business: @current_user.business,
        email: email,
        role: @role,
      )
    end
  end
end
