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
        update_portfolio
      rescue
        raise ActiveRecord::Rollback
      end
    end
    false
  end

  private

  def update_user
    record_error { @current_user.update!(name: @params[:user_name]) }

    emails = @params[:new_users].split(',').map(&:trim)
    emails.each do |email|
      if User.find_by(email: email)
        record_error("User: #{email} already exists")
      elsif email !~ /.+@.+\..+/
        record_error("Invalid email addres: #{email}")
      else
        record_error { User.create!(email: email) }
      end
    end
  end

  def update_business
    record_error { @current_user.business.update!(name: @params[:business_name]) }
  end

  def update_portfolio
    @params[:portfolio].each do |id, values|
      portfolio = Portfolio.find_by(id: id)
      if portfolio
        record_error { portfolio.update!(values.permit(:name)) }
      else
        record_error('Invalid portfolio ID')
      end
    end
  end

  def record_error(msg = nil)
    @errors << msg if msg
    return unless block_given?
    begin
      yield
    rescue => e
      @errors << e.message
      raise
    end
  end
end
