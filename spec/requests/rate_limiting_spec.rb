require 'spec_helper'

# Rails' `rate_limit` counts through Rails.cache, so these only mean anything
# with a real cache store configured (see config/environments/test.rb -- the
# suite previously used :null_store, which made every limit a silent no-op).
describe 'Authentication rate limiting', type: :request do
  let(:throttle_message) { I18n.t('devise.failure.too_many_requests') }

  describe 'sign in' do
    def attempt_sign_in
      post user_session_path,
           params: { user: { email: 'nobody@example.com', password: 'wrong-password' } }
    end

    it 'allows attempts up to the limit' do
      10.times { attempt_sign_in }

      expect(flash[:alert]).not_to eq(throttle_message)
    end

    it 'throttles the attempt after the limit' do
      11.times { attempt_sign_in }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(throttle_message)
    end

    it 'lets attempts through again once the window has passed' do
      11.times { attempt_sign_in }
      expect(flash[:alert]).to eq(throttle_message)

      travel(4.minutes) do
        attempt_sign_in
        expect(flash[:alert]).not_to eq(throttle_message)
      end
    end

    it 'throttles before checking credentials, so a valid password cannot bypass it' do
      user = create(:user, password: 'correct-horse-battery')
      11.times { attempt_sign_in }

      post user_session_path,
           params: { user: { email: user.email, password: 'correct-horse-battery' } }

      expect(flash[:alert]).to eq(throttle_message)
    end
  end

  describe 'sign up' do
    def attempt_sign_up
      post user_registration_path,
           params: { user: { email: "spam#{SecureRandom.hex(4)}@example.com",
                             username: "spam#{SecureRandom.hex(4)}",
                             password: 'a-perfectly-fine-password' } }
    end

    it 'throttles mass account creation after the limit' do
      expect { 11.times { attempt_sign_up } }.to change(User, :count).by(10)

      expect(response).to redirect_to(new_user_registration_path)
      expect(flash[:alert]).to eq(throttle_message)
    end
  end
end
