class TimeOffRequest < ApplicationRecord
  belongs_to :user

  validates :start_date, :end_date, presence: true
  validates :reason, length: { maximum: 500 }

  validate :end_date_must_be_after_or_equal_to_start_date, if: -> { dates_changed? }
  validate :no_overlapping_time_off_requests, if: -> { dates_changed? }

  enum :request_type, { vacation: 0, incapacity: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  private

  def self.overlapping_time_off_requests?(user_id, start_date, end_date)
    where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date).exists?(user_id: user_id)
  end

  def end_date_must_be_after_or_equal_to_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, "must be on or after the start date") if end_date < start_date
  end

  def no_overlapping_time_off_requests
    return if start_date.blank? || end_date.blank?

    if TimeOffRequest.overlapping_time_off_requests?(user_id, start_date, end_date)
      errors.add(:base, "You already have a time off request in this period")
    end
  end

  def dates_changed?
    will_save_change_to_start_date? || will_save_change_to_end_date?
  end
end
