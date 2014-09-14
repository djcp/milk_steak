module Controllers
  module SessionHelpers
    def sign_in_user(user)
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::SessionHelpers, :type => :controller
end
