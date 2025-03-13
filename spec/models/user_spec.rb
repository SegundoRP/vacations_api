require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:subordinates) }
    it { is_expected.to have_many(:time_off_requests).dependent(:destroy) }
    it { is_expected.to belong_to(:leader).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(normal: 0, admin: 1) }
    it { is_expected.to define_enum_for(:position).with_values(employee: 0, leader: 1, ceo: 2) }
  end
end
