# frozen_string_literal: true

# Example model with multi-tenancy and best practices
class ExampleModel < ApplicationRecord
  # Associations
  belongs_to :organization
  has_many :related_records, dependent: :destroy

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[pending active completed] }
  validate :custom_validation, on: :create

  # Callbacks
  before_validation :normalize_data
  after_create :send_notification

  # Enums
  enum :status, {
    pending: 'pending',
    active: 'active',
    completed: 'completed'
  }, prefix: true

  # Class methods
  def self.within_quota?
    Current.organization.within_quota?(:example_models)
  end

  # Instance methods
  def display_name
    "#{name} (#{status})"
  end

  private

  def normalize_data
    self.name = name&.strip
  end

  def custom_validation
    errors.add(:base, 'Custom validation failed') if some_condition?
  end

  def send_notification
    # NotificationJob.perform_later(id)
  end

  def some_condition?
    false
  end
end
