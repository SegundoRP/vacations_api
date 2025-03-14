require 'rails_helper'

RSpec.describe TimeOffRequest do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_length_of(:reason).is_at_most(500) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:request_type).with_values(vacation: 0, incapacity: 1) }
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2) }
  end

  shared_context 'when the request overlaps with another approved request' do
    let(:overlapping_request) do
      create(:time_off_request, :approved, user: user, start_date: Date.yesterday, end_date: Date.tomorrow)
    end
  end

  shared_context 'when the request does not overlap with another approved request' do
    let(:non_overlapping_request) do
      create(:time_off_request, user: user, start_date: Date.current, end_date: Date.current)
    end
  end

  describe '.overlapping_time_off_requests' do
    let(:user) { create(:user) }
    let(:overlapping_request) do
      create(:time_off_request, :approved, user: user, start_date: Date.yesterday, end_date: Date.tomorrow)
    end
    let(:non_overlapping_request) do
      create(:time_off_request, user: user, start_date: Date.current, end_date: Date.current)
    end

    context 'when the request overlaps with another approved request' do
      include_context 'when the request overlaps with another approved request'

      it 'returns true' do
        overlapping_request
        expect(TimeOffRequest.overlapping_time_off_requests?(
          user_id: user.id,
          start_date: Date.current,
          end_date: 2.days.from_now,
          request_type: overlapping_request.request_type
        )).to be_truthy
      end
    end

    context 'when the request does not overlap with another approved request' do
      include_context 'when the request does not overlap with another approved request'

      it 'returns false' do
        overlapping_request
        expect(TimeOffRequest.overlapping_time_off_requests?(
          user_id: user.id,
          start_date: 4.days.from_now,
          end_date: 6.days.from_now,
          request_type: overlapping_request.request_type
        )).to be_falsey
      end
    end
  end

  describe '#end_date_must_be_after_or_equal_to_start_date' do
    context 'when end date is before start date' do
      it 'is invalid' do
        time_off_request = build(:time_off_request, start_date: Date.current, end_date: Date.yesterday)
        time_off_request.valid?
        expect(time_off_request.errors[:end_date]).to include(
          I18n.t('activerecord.attributes.time_off_request.end_date_must_be_after_or_equal_to_start_date')
        )
      end
    end

    context 'when end date is equal to start date' do
      it 'is valid' do
        time_off_request = build(:time_off_request, start_date: Date.current, end_date: Date.current)
        time_off_request.valid?
        expect(time_off_request.errors[:end_date]).to be_empty
      end
    end
  end

  describe '#no_overlapping_time_off_requests' do
    let(:user) { create(:user) }

    context 'when the request does not overlap with another approved request' do
      include_context 'when the request does not overlap with another approved request'

      it 'is valid' do
        non_overlapping_request.no_overlapping_time_off_requests
        expect(non_overlapping_request.errors[:base]).to be_empty
      end
    end

    context 'when the request overlaps with another approved request' do
      include_context 'when the request overlaps with another approved request'

      it 'is invalid' do
        overlapping_request.no_overlapping_time_off_requests
        expect(overlapping_request.errors[:base]).to include(
          I18n.t('activerecord.attributes.time_off_request.overlapping_time_off_requests', user_name: user.name)
        )
      end
    end
  end

  describe '#dates_changed?' do
    context 'when the dates have changed' do
      it 'returns true' do
        time_off_request = build(:time_off_request)
        expect(time_off_request.send(:dates_changed?)).to be_truthy
      end
    end

    context 'when the dates have not changed' do
      it 'returns false' do
        time_off_request = create(:time_off_request)
        expect(time_off_request.send(:dates_changed?)).to be_falsey
      end
    end
  end
end
