# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  has_many :subordinates, class_name: "User", foreign_key: "leader_id"
  belongs_to :leader, class_name: "User", optional: true
  has_many :time_off_requests, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  enum :role, { normal: 0, admin: 1 }
  enum :position, { employee: 0, leader: 1, ceo: 2 }

  def vacation_days_by_year(year)
    time_off_requests
      .where(request_type: "vacation", status: "approved")
      .where("extract(year from start_date) = ?", year)
      .sum("end_date - start_date + 1")
  end
end
