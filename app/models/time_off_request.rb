class TimeOffRequest < ApplicationRecord
  belongs_to :user

  validates :start_date, :end_date, presence: true
  validates :reason, length: { maximum: 500 }

  validate :end_date_must_be_after_or_equal_to_start_date, if: -> { dates_changed? }
  validate :no_overlapping_time_off_requests, if: -> { dates_changed? }

  enum :request_type, { vacation: 0, incapacity: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  def self.overlapping_time_off_requests?(user_id, start_date, end_date)
    where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date).exists?(user_id: user_id, status: [:approved])
  end

  def end_date_must_be_after_or_equal_to_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date,
                 I18n.t('activerecord.attributes.time_off_request.end_date_must_be_after_or_equal_to_start_date'))
    end
  end

  def no_overlapping_time_off_requests
    return if start_date.blank? || end_date.blank?

    if TimeOffRequest.overlapping_time_off_requests?(user_id, start_date, end_date)
      errors.add(:base, I18n.t('activerecord.attributes.time_off_request.overlapping_time_off_requests'))
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id start_date end_date request_type status reason user_id created_at updated_at]
  end

  private

  def dates_changed?
    will_save_change_to_start_date? || will_save_change_to_end_date?
  end
end
