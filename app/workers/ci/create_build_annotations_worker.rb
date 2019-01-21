# frozen_string_literal: true

module Ci
  # Sidekiq worker for storing the build annotations produced by a CI build.
  class CreateBuildAnnotationsWorker
    include ApplicationWorker

    # @param [Integer] build_id
    def perform(build_id)
      if (build = Ci::Build.find_by_id(build_id))
        CreateBuildAnnotationsService.new(build).execute
      end
    end
  end
end
