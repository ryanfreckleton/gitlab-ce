# frozen_string_literal: true

class SuggestionEntity < Grape::Entity
  expose :id
  expose :from_line
  expose :to_line
  expose :appliable?, as: :appliable
  expose :changing
  expose :suggestion
  expose :relative_order
end
