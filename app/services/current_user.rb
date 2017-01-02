class CurrentUser
  class << self
    attr_writer :finder

    def finder
      @finder || FromSession
    end

    delegate :get, to: :finder
  end

  class FromSession
    def self.get(controller)
      return nil unless controller.session[:user_id]
      user = User.find(controller.session[:user_id])
      if user.oauth_expires_at < Time.zone.now
        controller.session[:user_id] = nil
        return nil
      end
      user
    end
  end

  class FakeGetter
    def self.get(_)
      User.first
    end
  end
end

CurrentUser.finder = CurrentUser::FakeGetter if Rails.env.development?
