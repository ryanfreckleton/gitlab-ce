# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::SentryIssuesService do
  subject(:service) { described_class.new(sentry_url, token) }

  let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project' }
  let(:token) { 'test-token' }
  let(:sample_response) do
    [{
      "lastSeen": "2018-12-31T12:00:11Z",
      "numComments": 0,
      "userCount": 0,
      "stats": {
        "24h": [
          [
            1546437600,
            0
          ]
        ]
      },
      "culprit": "sentry.tasks.reports.deliver_organization_user_report",
      "title": "gaierror: [Errno -2] Name or service not known",
      "id": "11",
      "assignedTo": nil,
      "logger": nil,
      "type": "error",
      "annotations": [],
      "metadata": {
        "type": "gaierror",
        "value": "[Errno -2] Name or service not known"
      },
      "status": "unresolved",
      "subscriptionDetails": nil,
      "isPublic": false,
      "hasSeen": false,
      "shortId": "INTERNAL-4",
      "shareId": nil,
      "firstSeen": "2018-12-17T12:00:14Z",
      "count": "21",
      "permalink": "35.228.54.90/sentry/internal/issues/11/",
      "level": "error",
      "isSubscribed": true,
      "isBookmarked": false,
      "project": {
        "slug": "internal",
        "id": "1",
        "name": "Internal"
      },
      "statusDetails": {}
    }.with_indifferent_access]
  end

  describe '#execute' do
    let(:return_value) do
      stub_sentry_request(sentry_url + '/issues/?limit=20&query=is:unresolved', body: sample_response)
      service.execute
    end

    it 'returns objects of type ErrorTracking::Error' do
      expect(return_value.length).to eq(1)
      expect(return_value[0]).to be_a(ErrorTracking::Error)
    end

    using RSpec::Parameterized::TableSyntax

    where(:error_object, :sentry_response) do
      :id           | :id
      :first_seen   | :firstSeen
      :last_seen    | :lastSeen
      :title        | :title
      :type         | :type
      :user_count   | :userCount
      :count        | :count
      :message      | [:metadata, :value]
      :culprit      | :culprit
      :external_url | :permalink
      :short_id     | :shortId
      :status       | :status
      :frequency    | [:stats, '24h']
      :project_id   | [:project, :id]
      :project_name | [:project, :name]
      :project_slug | [:project, :slug]
    end

    with_them do
      it { expect(return_value[0].public_send(error_object)).to eq(sample_response[0].dig(*sentry_response)) }
    end

    context 'redirects' do
      let(:redirect_to) { 'https://redirected.example.com' }
      let(:other_url) { 'https://other.example.org' }

      let!(:redirect_req_stub) do
        stub_sentry_request(
          sentry_url + '/issues/?limit=20&query=is:unresolved',
          status: 302,
          headers: { location: redirect_to }
        )
      end
      let!(:redirected_req_stub) { stub_sentry_request(other_url) }

      it 'does not follow redirects' do
        expect { service.execute }.to raise_exception(ErrorTracking::SentryIssuesService::Error, 'Sentry response error: 302')
        expect(redirect_req_stub).to have_been_requested
        expect(redirected_req_stub).not_to have_been_requested
      end
    end

    # Sentry API returns 404 if there are extra slashes in the URL!
    context 'extra slashes in URL' do
      subject(:service) { described_class.new(sentry_url, token) }

      let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects//sentry-org/sentry-project/' }

      let!(:invalid_req_stub) { stub_sentry_request(sentry_url + '/issues/?limit=20&query=is:unresolved') }
      let!(:valid_req_stub) do
        stub_sentry_request(
          'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project/issues/?limit=20&query=is:unresolved'
        )
      end

      it 'removes extra slashes in api url' do
        service.execute

        expect(invalid_req_stub).not_to have_been_requested
        expect(valid_req_stub).to have_been_requested
      end
    end
  end

  describe '#external_url' do
    it 'returns the correct url' do
      expect(service.external_url).to eq('https://sentrytest.gitlab.com/sentry-org/sentry-project')
    end
  end

  private

  def stub_sentry_request(url, body: {}, status: 200, headers: {})
    WebMock.stub_request(:get, url)
      .to_return(
        status: status,
        headers: { 'Content-Type' => 'application/json' }.merge(headers),
        body: body.to_json
      )
  end
end
