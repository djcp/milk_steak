require 'spec_helper'

describe 'Authentication', type: :request do
  describe 'the approval gate' do
    # Controller specs stub current_user directly and so never exercise
    # active_for_authentication?. Posting real credentials is the only way to
    # cover the gate end to end.
    it 'refuses sign-in for an unapproved user' do
      user = create(:user, :pending, password: 'a-perfectly-fine-password')

      post user_session_path,
           params: { user: { email: user.email, password: 'a-perfectly-fine-password' } }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(I18n.t('devise.failure.pending_approval'))

      # No session was established: a page requiring sign-in still bounces.
      # (current_user isn't available here -- a failed sign-in is handled by
      # Devise::FailureApp, not a normal controller.)
      get new_recipe_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows sign-in once approved' do
      user = create(:user, :pending, password: 'a-perfectly-fine-password')
      user.update!(approved: true)

      post user_session_path,
           params: { user: { email: user.email, password: 'a-perfectly-fine-password' } }

      expect(response).to redirect_to(root_path)
      expect(controller.current_user).to eq(user)
    end

    it 'lets an unapproved admin through, since admin? short-circuits approved?' do
      admin = create(:user, :admin, approved: false, password: 'a-perfectly-fine-password')

      post user_session_path,
           params: { user: { email: admin.email, password: 'a-perfectly-fine-password' } }

      expect(controller.current_user).to eq(admin)
    end
  end

  describe 'user enumeration' do
    # config.paranoid = true. Note this covers only the "send instructions"
    # endpoints; sign-up still reports a taken email via :validatable, which is
    # an accepted limitation of :registerable.
    it 'gives the same password-reset response whether or not the address exists' do
      create(:user, email: 'known@example.com')

      post user_password_path, params: { user: { email: 'known@example.com' } }
      known = flash[:notice]

      post user_password_path, params: { user: { email: 'nobody@example.com' } }
      unknown = flash[:notice]

      expect(unknown).to eq(known)
      expect(unknown).to be_present
    end

    it 'does not reveal whether an address exists when resending confirmation' do
      create(:user, email: 'known2@example.com', confirmed_at: nil)

      post user_confirmation_path, params: { user: { email: 'known2@example.com' } }
      known = flash[:notice]

      post user_confirmation_path, params: { user: { email: 'nobody2@example.com' } }

      expect(flash[:notice]).to eq(known)
    end
  end

  describe 'password length' do
    it 'rejects a password below the configured minimum' do
      expect(Devise.password_length.min).to eq(12)

      expect do
        post user_registration_path,
             params: { user: { email: 'short@example.com', username: 'shortpw', password: 'a' * 11 } }
      end.not_to change(User, :count)
    end

    it 'accepts a password at the minimum' do
      expect do
        post user_registration_path,
             params: { user: { email: 'longer@example.com', username: 'longpw', password: 'a' * 12 } }
      end.to change(User, :count).by(1)
    end
  end
end
