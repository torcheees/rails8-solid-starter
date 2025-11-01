# frozen_string_literal: true

# Example Solid Queue job with multi-tenancy
class ExampleJob < ApplicationJob
  queue_as :default

  # Retry configuration
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError

  def perform(resource_id, organization_id = nil)
    # Set tenant context
    set_organization(organization_id)

    # Find resource
    resource = find_resource(resource_id)
    return if resource.nil?

    # Execute business logic
    execute_action(resource)

    # Clean up
    cleanup
  rescue StandardError => e
    handle_error(e, resource)
    raise
  end

  private

  def set_organization(organization_id)
    return unless organization_id

    Current.organization = Organization.find(organization_id)
  end

  def find_resource(resource_id)
    ExampleModel.find_by(id: resource_id)
  end

  def execute_action(resource)
    # Main job logic
    result = ExampleService.new(resource).execute

    # Update resource
    resource.update!(
      last_processed_at: Time.current,
      status: 'completed'
    )

    # Create audit log
    create_audit_log(resource, result)
  end

  def create_audit_log(resource, result)
    # AuditLog.create!(
    #   organization: Current.organization,
    #   action: 'example_job_executed',
    #   resource: resource,
    #   metadata: { result: result }
    # )
  end

  def cleanup
    # Clean up temporary files, connections, etc.
  end

  def handle_error(error, resource)
    Rails.logger.error("ExampleJob failed: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))

    # Update resource status
    resource&.update(status: 'failed', error_message: error.message)

    # Notify administrators
    # AdminMailer.job_failed(resource, error).deliver_later
  end
end
