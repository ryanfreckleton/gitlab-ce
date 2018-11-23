FactoryBot.define do
  factory :suggestion do
    association :note, :diff_note_on_merge_request
    changing 'foo'
    suggestion 'bar'
  end
end
