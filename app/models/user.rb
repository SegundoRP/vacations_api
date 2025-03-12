# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  devise :database_authenticatable, :registerable

  include DeviseTokenAuth::Concerns::User

  has_many :subordinates, class_name: "User", foreign_key: "leader_id"
  belongs_to :leader, class_name: "User", optional: true
  has_many :time_off_requests, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  enum :role, { normal: 0, admin: 1 }
end
