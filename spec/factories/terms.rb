FactoryBot.define do
  factory :term, class: ApplicationSetting::Term do
    terms _("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end
end
