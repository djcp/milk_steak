module Controllers
  module SessionHelpers
    def sign_in_user(user)
      request.env['warden'].stub(authenticate!: user)
      controller.stub(current_user: user)
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::SessionHelpers, :type => :controller
end
