class ConfigUpdater
  attr_reader :errors
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @errors = []
  end

  def update
    ApplicationRecord.transaction do
      begin
        update_user
        update_business
        return true
        # update_portfolio
      rescue => e
        raise ActiveRecord::Rollback
      end
    end
    return false
  end

  private

  def update_user
    record_error { @current_user.update!(name: @params[:user_name]) }

    emails = @params[:new_users].split(',').map(&:trim)
    emails.each do |email|
      record_error("User: #{email} already exists") if User.find_by(email: email)
      record_error("Invalid email addres: #{email}") unless email =~ /.+@.+\..+/
      record_error { User.create!(email: email) }
    end
  end

  def update_business
    record_error { @current_user.business.update!(name: @params[:business_name]) }
  end

  def record_error(msg=nil, &block)
    @errors << msg if msg
    if block_given?
      begin
        block.call
      rescue => e
        @errors << e.message
        raise
      end
    end
  end
end
