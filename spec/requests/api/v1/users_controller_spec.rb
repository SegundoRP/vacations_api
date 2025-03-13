require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  describe 'GET #vacation_days' do
    context 'when the user is not logged in' do
      it 'returns a 401 status' do
        get vacation_days_api_v1_user_path(0), params: { year: 2025 }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is logged in' do
      let(:user) { create(:user) }
      let(:headers) { user.create_new_auth_token }
      let!(:time_off_request) do
        create(:time_off_request, :approved, user: user, start_date: '2025-01-01', end_date: '2025-01-05')
      end

      before do
        sign_in user
      end

      it 'returns success status' do
        get vacation_days_api_v1_user_path(user), params: { year: 2025 }, headers: headers
        expect(response).to be_successful
      end

      it 'returns the vacation days for the user' do
        get vacation_days_api_v1_user_path(user), params: { year: 2025 }, headers: headers
        expect(response.body).to include('5')
      end
    end
  end
end
