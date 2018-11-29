# frozen_string_literal: true

# Reports slow example runtimes to a configured Sentry DSN
class SlowExampleListener
  # Maximum execution time for a single example
  DEFAULT_THRESHOLD = 10.0

  # Type-specific maximum execution times for a single example
  TYPE_THRESHOLDS = {
    feature: -> (meta) { meta[:js] ? 20.0 : DEFAULT_THRESHOLD }
  }.freeze

  def self.enabled?
    (ENV['CI'] || ENV['ENABLE_RSPEC_TIMINGS']) &&
      ENV['RSPEC_TIMINGS_DSN'].present?
  end

  def initialize
    @raven = Raven::Instance.new(Raven::Context.new, Raven::Configuration.new)
    @raven.configure do |config|
      config.dsn = ENV['RSPEC_TIMINGS_DSN']
      config.silence_ready = true
    end
  end

  def threshold(meta)
    threshold = TYPE_THRESHOLDS.fetch(meta[:type], DEFAULT_THRESHOLD)

    if threshold.respond_to?(:call)
      threshold.call(meta)
    else
      threshold
    end
  end

  def example_passed(notification)
    example = notification.example
    metadata = example.metadata
    result = example.execution_result
    threshold = threshold(metadata)

    if result.run_time > threshold
      message = "Slow example: #{metadata[:location]}"

      extra = metadata
        .slice(:file_path, :line_number, :location, :full_description)
        .merge({ run_time: result.run_time, threshold: threshold })

      capture_message(
        message,
        extra: extra,
        fingerprint: fingerprint(metadata),
        tags: metadata.slice(:type, :js)
      )
    end
  rescue StandardError => ex
    @raven.capture_exception(ex)
  end

  private

  def fingerprint(meta)
    # Fingerprint on the full description, otherwise the example's location
    # changing would create a new event
    [Digest::SHA256.hexdigest(meta[:full_description])]
  end

  def capture_message(message, options = {})
    # Temporarily disable WebMock so that Raven can post the message
    WebMock.disable!
    @raven.capture_message(message, options)
    WebMock.enable!
  end
end

if SlowExampleListener.enabled?
  RSpec.configure do |config|
    config.reporter.register_listener SlowExampleListener.new, :example_passed
  end
end
