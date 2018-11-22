# frozen_string_literal: true

class MergeRequestPipelinesFinder
  attr_reader :merge_request, :pipelines, :params

  ALLOWED_INDEXED_COLUMNS = %w[id status ref user_id].freeze

  def initialize(merge_request, params = {})
    @merge_request = merge_request
    @pipelines = merge_request&.source_project&.pipelines
    @params = params
  end

  def execute
    return Ci::Pipeline.none if pipelines.nil?

    items = with_source_branch_ref(pipelines)
    items = by_sha(items)
    sort_items(items)
  end

  private

  # rubocop: disable CodeReuse/ActiveRecord
  def by_sha(items)
    if params[:sha].present?
      items.where(sha: params[:sha])
    else
      items
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def with_source_branch_ref(items)
    items.where(ref: merge_request.source_branch)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def sort_items(items)
    order_by = if ALLOWED_INDEXED_COLUMNS.include?(params[:order_by])
                 params[:order_by]
               else
                 :id
               end

    sort = if params[:sort] =~ /\A(ASC|DESC)\z/i
             params[:sort]
           else
             :desc
           end

    items.order(order_by => sort)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
