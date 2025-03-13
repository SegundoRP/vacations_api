require 'rails_helper'

RSpec.describe Api::V1::TimeOffRequestsController do
  shared_context 'when the user is logged in' do
    let(:user) { create(:user) }
    let(:headers) { user.create_new_auth_token }
    let!(:time_off_request) { create(:time_off_request, :approved, user: user) }

    before do
      sign_in user
    end
  end

  shared_examples 'unauthorized response' do
    it 'returns a 401 status' do
      get api_v1_time_off_requests_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  shared_examples 'successful response' do
    it 'returns a success status' do
      get api_v1_time_off_requests_path, headers: headers
      expect(response).to be_successful
    end
  end

  describe 'GET #index' do
    context 'when the user is not logged in' do
      it_behaves_like 'unauthorized response'
    end

    context 'when the user is logged in' do
      include_context 'when the user is logged in'

      it_behaves_like 'successful response'

      it 'returns a list of time off requests' do
        get api_v1_time_off_requests_path, headers: headers
        expect(response.body).to include(time_off_request.start_date.to_s)
        expect(response.body).to include(time_off_request.end_date.to_s)
        expect(response.body).to include(time_off_request.request_type)
        expect(response.body).to include(time_off_request.status)
        expect(response.body).to include(time_off_request.reason)
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is not logged in' do
      it_behaves_like 'unauthorized response'
    end

    context 'when the user is logged in' do
      include_context 'when the user is logged in'

      it_behaves_like 'successful response'

      it 'returns a time off request' do
        get api_v1_time_off_request_path(time_off_request), headers: headers
        expect(response.body).to include(time_off_request.start_date.to_s)
        expect(response.body).to include(time_off_request.end_date.to_s)
        expect(response.body).to include(time_off_request.request_type)
        expect(response.body).to include(time_off_request.status)
        expect(response.body).to include(time_off_request.reason)
      end
    end
  end

  describe 'POST #create' do
    context 'when the user is not logged in' do
      it_behaves_like 'unauthorized response'
    end

    context 'when the user is logged in' do
      let(:params) do
         { time_off_request:
            {
              start_date: '2025-01-01',
              end_date: '2025-01-05',
              user_id: user.id,
              request_type: 'vacation',
              status: 'approved',
              reason: 'Vacation',
            },
          }
      end

      include_context 'when the user is logged in'

      it_behaves_like 'successful response'

      it 'creates a time off request' do
        post api_v1_time_off_requests_path, params: params, headers: headers
        expect(response.body).to include(params[:time_off_request][:start_date].to_s)
        expect(response.body).to include(params[:time_off_request][:end_date].to_s)
        expect(response.body).to include(params[:time_off_request][:request_type])
        expect(response.body).to include(params[:time_off_request][:status])
        expect(response.body).to include(params[:time_off_request][:reason])
      end
    end
  end

  describe 'PUT #update' do
    context 'when the user is not logged in' do
      it_behaves_like 'unauthorized response'
    end

    context 'when the user is logged in' do
      let(:params) do
        { time_off_request:
          {
            status: 'rejected',
          },
        }
      end

      include_context 'when the user is logged in'

      it_behaves_like 'successful response'

      it 'updates a time off request' do
        put api_v1_time_off_request_path(time_off_request), params: params, headers: headers
        expect(response.parsed_body['data']['attributes']['status']).to eq(time_off_request.reload.status)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is not logged in' do
      it_behaves_like 'unauthorized response'
    end

    context 'when the user is logged in' do
      include_context 'when the user is logged in'

      it_behaves_like 'successful response'

      it 'deletes a time off request' do
        delete api_v1_time_off_request_path(time_off_request), headers: headers
        expect(TimeOffRequest.count).to eq(0)
      end
    end
  end
end
