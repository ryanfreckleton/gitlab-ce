# frozen_string_literal: true

module ErrorTracking
  class SentryIssuesService
    def initialize(url, token)
      @url = URI(url + '/issues/')
      @token = token
    end

    def execute(limit: 20, issue_status: 'unresolved')
      sentry_query = {
        query: "is:#{issue_status}",
        limit: limit
      }
      # "query=is:unresolved&limit=#{limit}&sort=date&statsPeriod=24h&shortIdLookup=1"

      Gitlab::HTTP.get(@url.to_s,
        query: sentry_query,
        headers: {
        'Authorization' => "Bearer #{@token}"
      })
    end
  end
end
