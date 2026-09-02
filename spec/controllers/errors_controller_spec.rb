require 'spec_helper'

describe ErrorsController do
  # Only 400/404/406/422/500 have routes, so the unknown-status fallback is
  # unreachable by a direct GET -- it exists for statuses Rails hands to
  # config.exceptions_app (a 502, say), which arrive with PATH_INFO set and no
  # matching route. Driving the action directly is the only way to cover it.
  describe '#show with an unmapped status' do
    it 'falls back to the 500 copy' do
      request.path_info = '/502'

      get :show

      expect(response).to have_http_status(:internal_server_error)
      expect(assigns(:status)).to eq(500)
      expect(assigns(:title)).to eq(ErrorsController::ERROR_PAGE_COPY.fetch(500).first)
    end

    it 'falls back for a non-numeric path too' do
      request.path_info = '/not-a-status'

      get :show

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
