require 'spec_helper'

describe Admin::UsersController do
  describe 'non-admin access' do
    context 'when guest' do
      it 'redirects from index' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when regular user' do
      before { sign_in_user build(:user) }

      it 'redirects from index' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'admin access' do
    let(:admin) { build(:user, :admin) }

    before { sign_in_user admin }

    describe '#index' do
      it 'is successful' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns pending users (non-admin, unapproved)' do
        pending_user  = create(:user, :pending)
        approved_user = create(:user)
        create(:user, :admin)

        get :index

        expect(assigns(:pending_users)).to include(pending_user)
        expect(assigns(:pending_users)).not_to include(approved_user)
      end

      it 'assigns approved users (non-admin, approved)' do
        pending_user  = create(:user, :pending)
        approved_user = create(:user)

        get :index

        expect(assigns(:approved_users)).to include(approved_user)
        expect(assigns(:approved_users)).not_to include(pending_user)
      end
    end

    describe '#approve' do
      it 'approves the user and redirects' do
        user = create(:user, :pending)

        patch :approve, params: { id: user.id }

        expect(user.reload.approved).to be true
        expect(response).to redirect_to(admin_users_path)
      end

      it 'sets a notice with the username' do
        user = create(:user, :pending)

        patch :approve, params: { id: user.id }

        expect(flash[:notice]).to include(user.username)
      end
    end
  end
end
