module ErrorTracking
  class SentryService

    attr_accessor :uri, :token

    def initialize(host, port, organisation, project_name, token)
      @uri = URI('')
      @uri.scheme = 'http'
      @uri.host = host
      @uri.port = port
      @uri.path = "/api/0/projects/#{organisation}/#{project_name}/"
      @token = token
    end

    def get_issues
      @uri.path += 'issues/'
      # @uri.query = 'query=is:unresolved&limit=25&sort=date&statsPeriod=24h&shortIdLookup=1'

      Gitlab::HTTP.get(@uri.to_s, query: @uri.query, headers: {
        'Authorization' => "Bearer #{@token}"
      })
    end
  end
end
