# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ErrorTrackingController, type: :controller do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  describe 'GET #list' do
    it 'renders index with 200 status code' do
      get :list, params: project_params

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:list)
    end

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(error_tracking: false)
      end

      it 'returns 404' do
        get :list, params: project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with insufficient permissions' do
      before do
        project.add_guest(user)
      end

      it 'returns 404' do
        get :list, params: project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :list, params: project_params

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #index' do
    shared_examples 'no data' do
      it 'returns no data' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('error_tracking/index')
        expect(json_response['external_url']).to be_nil
        expect(json_response['errors']).to eq([])
      end
    end

    context 'with error tracking enabled' do
      let(:issues_service) { spy(:sentry_issues_service) }
      let(:external_url) { 'http://example.com' }

      let!(:setting) do
        create(:project_error_tracking_setting, project: project, enabled: true)
      end

      before do
        expect(ErrorTracking::SentryIssuesService)
          .to receive(:new).with(setting.api_url, setting.token)
          .and_return(issues_service)
      end

      context 'with errors' do
        before do
          expect(issues_service).to receive(:execute).and_return([error])
          expect(issues_service).to receive(:external_url).and_return(external_url)
        end

        let(:error) { build_error_tracking_error }

        it 'returns a list of errors' do
          get :index, params: project_params

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('error_tracking/index')
          expect(json_response['external_url']).to eq(external_url)
          expect(json_response['errors']).to eq([error].as_json)
        end
      end
    end

    context 'with error tracking disabled' do
      before do
        create(:project_error_tracking_setting, project: project, enabled: false)
        expect(ErrorTracking::SentryIssuesService).not_to receive(:new)
      end

      it_behaves_like 'no data'
    end

    context 'without error tracking setting' do
      before do
        expect(ErrorTracking::SentryIssuesService).not_to receive(:new)
      end

      it_behaves_like 'no data'
    end

    context 'without error tracking setting' do
      it 'returns no data' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('error_tracking/index')
        expect(json_response['external_url']).to be_nil
        expect(json_response['errors']).to eq([])
      end
    end

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(error_tracking: false)
      end

      it 'returns 404' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with insufficient permissions' do
      before do
        project.add_guest(user)
      end

      it 'returns 404' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :index, params: project_params

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  private

  def project_params
    { namespace_id: project.namespace, project_id: project }
  end

  def build_error_tracking_error
    ErrorTracking::Error.new(
      id: 'id',
      title: 'title',
      type: 'error',
      user_count: 1,
      count: 2,
      first_seen: Time.now,
      last_seen: Time.now,
      message: 'message',
      culprit: 'culprit',
      external_url: 'http://example.com/id',
      project_id: 'project1',
      project_name: 'project name',
      project_slug: 'project_name',
      short_id: 'ID',
      status: 'unresolved'
    )
  end
end
