# frozen_string_literal: true

module API
  class Version < Grape::API
    before { authenticate! }

    desc _('Get the version information of the GitLab instance.') do
      detail _('This feature was introduced in GitLab 8.13.')
    end
    get '/version' do
      { version: Gitlab::VERSION, revision: Gitlab.revision }
    end
  end
end
