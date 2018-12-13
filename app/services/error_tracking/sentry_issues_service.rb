# frozen_string_literal: true

module ErrorTracking
  class SentryIssuesService
    def initialize(url, token)
      @url = URI(url)
      @token = token
    end

    def execute(limit: 20, issue_status: 'unresolved')
      external_url = extract_external_url
      issues = get_issues(limit, issue_status)
      errors = map_to_errors(issues)

      [external_url, errors]
    end

    private

    # http://HOST/api/0/projects/ORG/PROJECT
    # ->
    # http://HOST/ORG/PROJECT
    def extract_external_url
      @url.to_s.sub('api/0/projects/', '')
    end

    def get_issues(limit, issue_status)
      issues_url = "#{@url}/issues/"
      sentry_query = {
        query: "is:#{issue_status}",
        limit: limit
      }
      # "query=is:unresolved&limit=#{limit}&sort=date&statsPeriod=24h&shortIdLookup=1"

      resp = Gitlab::HTTP.get(issues_url,
        query: sentry_query,
        headers: {
        'Authorization' => "Bearer #{@token}"
      })

      if resp.code == 200
        resp.as_json
      else
        # TODO: Handle non 200 status (error)
        []
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
      count, frequency = fake_freq(frequency)

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
        project_slug: project.fetch('slug'),
      )
    end

    def fake_freq(frequency)
      faked = frequency.map do |(time, count)|
        [time, count == 0 ? 10 + rand(50) : count]
      end

      count = faked.reduce(0) { |sum, (_, c)| sum + c }

      [count, faked]
    end
  end
end
