# frozen_string_literal: true

class ProjectDailyStatistic < ActiveRecord::Base
  belongs_to :project

  scope :of_project, -> (project) { where(project: project) }
  scope :of_last_30_days, -> { where('date >= ?', 29.days.ago.to_date) }
  scope :sorted_by_date_desc, -> { order('project_id, date desc') }
  scope :sum_fetch_count, -> { sum(:fetch_count) }
end
