# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ErrorTrackingController, type: :controller do
  set(:project) { create(:project) }
  let(:user) { create(:user) }

  let(:json_response) { JSON.parse(response.body) }

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  describe 'GET #list' do
    it 'renders index with 200 status code' do
      get :list, project_params

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:list)
    end

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(error_tracking: false)
      end

      it 'returns 404' do
        get :list, project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :list, project_params

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #index' do
    it 'returns an empty list of errors' do
      get :index, project_params

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to eq([])
    end

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(error_tracking: false)
      end

      it 'returns 404' do
        get :index, project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  private

  def project_params
    { namespace_id: project.namespace, project_id: project }
  end
end
