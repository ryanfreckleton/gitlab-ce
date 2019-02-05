require_relative '../qa'

Dir[::File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  # If quarantine is focussed, skip tests/contexts that have other metadata
  # unless they're also focussed. This lets us run quarantined tests in a
  # particular category without running tests in other categories.
  # E.g., if a test is tagged 'smoke' and 'quarantine', and another is tagged
  # 'ldap' and 'quarantine', if we wanted to run just quarantined smoke tests
  # using `--tag quarantine --tag smoke`, without this check we'd end up
  # running that ldap test as well.
  config.before(:context, :quarantine) do
    if config.inclusion_filter[:quarantine] && self.class.metadata.keys.include?(:quarantine)
      skip("Only running contexts tagged with :quarantine and any of #{filters_other_than_quarantine(config)}") unless quarantine_and_optional_other_tag?(self.class.metadata.keys, config)
    end
  end
  config.before do |example|
    QA::Runtime::Logger.debug("Starting test: #{example.full_description}") if QA::Runtime::Env.debug?

    if config.inclusion_filter[:quarantine]
      skip("Only running tests tagged with :quarantine and any of #{filters_other_than_quarantine(config)}") unless quarantine_and_optional_other_tag?(example.metadata.keys, config)
    end
  end

  # Skip tests in quarantine unless we explicitly focus on them.
  # Skip the entire context if a context is tagged. This avoids running before
  # blocks unnecessarily.
  # We could use an exclusion filter, but this way the test report will list
  # the quarantined tests when they're not run so that we're aware of them
  [:context, :each].each do |scope|
    config.before(:context, :quarantine) do |context|
      skip('In quarantine') unless config.inclusion_filter[:quarantine]
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

def filters_other_than_quarantine(config)
  config.inclusion_filter.rules.keys.reject { |key| key == :quarantine }
end

# Checks if a test has the 'quarantine' tag and other tags in the inclusion filter.
#
# Returns true if
# - the metadata includes the quarantine tag
# - and the metadata and inclusion filter both have any other tag
# - or no other tags are in the inclusion filter
def quarantine_and_optional_other_tag?(metadata_keys, config)
  return false unless metadata_keys.include? :quarantine
  return true if filters_other_than_quarantine(config).empty?

  filters_other_than_quarantine(config).any? { |key| metadata_keys.include? key }
end
