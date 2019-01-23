# frozen_string_literal: true

require_relative 'gt_one_coercion'

class UnfoldForm
  include Virtus.model

  attribute :since, GtOneCoercion
  attribute :to, GtOneCoercion
  attribute :bottom, Boolean
  attribute :unfold, Boolean, default: true
  attribute :full, Boolean, default: false
  attribute :offset, Integer
  attribute :indent, Integer, default: 0
end
