# frozen_string_literal: true

# Example service class for business logic
class ExampleService
  attr_reader :resource, :options

  def initialize(resource, options = {})
    @resource = resource
    @options = options
  end

  # Main entry point
  def execute
    validate_preconditions!
    perform_action
    handle_result
  rescue StandardError => e
    handle_error(e)
  end

  # Test connection (for external services)
  def self.test_connection(config)
    new(config).test
  end

  def test
    validate_configuration!
    perform_test_action
    { success: true, message: 'Test successful' }
  rescue StandardError => e
    { success: false, message: e.message }
  end

  private

  def validate_preconditions!
    raise ArgumentError, 'Resource cannot be nil' if resource.nil?
    raise ArgumentError, 'Invalid status' unless valid_status?
  end

  def validate_configuration!
    raise ArgumentError, 'Missing required configuration' unless configured?
  end

  def perform_action
    # Main business logic here
    result = external_api_call if options[:use_external]
    update_resource(result)
  end

  def perform_test_action
    # Test logic here
    external_api_call
  end

  def handle_result
    create_audit_log
    send_notification if options[:notify]
    resource
  end

  def handle_error(error)
    Rails.logger.error("ExampleService error: #{error.message}")
    create_error_log(error)
    raise error
  end

  def external_api_call
    # Example: HTTP request to external API
    # response = HTTParty.get(api_url, headers: headers)
    # JSON.parse(response.body)
  end

  def update_resource(result)
    resource.update!(
      last_checked_at: Time.current,
      result: result
    )
  end

  def create_audit_log
    # AuditLog.create!(
    #   organization: Current.organization,
    #   user: Current.user,
    #   action: 'example_action',
    #   resource: resource
    # )
  end

  def create_error_log(error)
    # ErrorLog.create!(
    #   organization: Current.organization,
    #   error_type: error.class.name,
    #   error_message: error.message,
    #   resource: resource
    # )
  end

  def send_notification
    # NotificationJob.perform_later(resource.id)
  end

  def valid_status?
    %w[pending active].include?(resource.status)
  end

  def configured?
    options[:api_key].present?
  end
end
