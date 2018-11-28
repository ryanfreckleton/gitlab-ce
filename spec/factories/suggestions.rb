# frozen_string_literal: true

FactoryBot.define do
  factory :suggestion do
    relative_order 0
    association :diff_note, factory: :diff_note_on_merge_request
    changing '    vars = {'
    suggestion '    vars = ['

    trait :unappliable do
      changing 'foo'
      suggestion 'foo'
    end
  end
end
