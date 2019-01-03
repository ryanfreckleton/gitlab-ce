# frozen_string_literal: true

module ErrorTracking
  class SentryIssuesService
    Error = Class.new(StandardError)

    def initialize(url, token)
      @url = url
      @token = token
    end

    def execute(limit: 20, issue_status: 'unresolved')
      issues = get_issues(limit, issue_status)
      map_to_errors(issues)
    end

    def external_url
      extract_external_url
    end

    private

    # http://HOST/api/0/projects/ORG/PROJECT
    # ->
    # http://HOST/ORG/PROJECT
    def extract_external_url
      @url.to_s.sub('api/0/projects/', '')
    end

    def issues_api_url
      issues_url = URI(@url + '/issues/')
      issues_url.path.squeeze!('/')

      issues_url
    end

    def get_issues(limit, issue_status)
      resp = Gitlab::HTTP.get(
        issues_api_url,
        query: {
          query: "is:#{issue_status}",
          limit: limit
        },
        headers: {
          'Authorization' => "Bearer #{@token}"
        },
        follow_redirects: false
      )

      handle_response(resp)
    end

    def handle_response(response)
      if response.code == 200
        response.as_json
      else
        raise SentryIssuesService::Error, "Sentry response error: #{response.code}"
      end
    end

    def map_to_errors(issues)
      issues.map do |issue|
        map_to_error(issue)
      end
    end

    def map_to_error(issue)
      project = issue.fetch('project')
      metadata = issue.fetch('metadata')

      count = issue.fetch('count')
      frequency = issue.fetch('stats').fetch('24h')

      ErrorTracking::Error.new(
        id: issue.fetch('id'),
        first_seen: issue.fetch('firstSeen'),
        last_seen: issue.fetch('lastSeen'),
        title: issue.fetch('title'),
        type: issue.fetch('type'),
        user_count: issue.fetch('userCount'),
        count: count,
        message: metadata.fetch('value', nil),
        culprit: issue.fetch('culprit'),
        external_url: issue.fetch('permalink'),
        short_id: issue.fetch('shortId'),
        status: issue.fetch('status'),
        frequency: frequency,
        project_id: project.fetch('id'),
        project_name: project.fetch('name'),
        project_slug: project.fetch('slug')
      )
    end
  end
end
