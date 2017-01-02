module WithUser
  def with_user(user)
    finder = CurrentUser.finder

    CurrentUser.finder = double(:finder, get: user)

    yield
  ensure
    CurrentUser.finder = finder
  end
end

RSpec.configure do |config|
  config.include WithUser
end
