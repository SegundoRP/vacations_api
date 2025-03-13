# spec/services/spreadsheet_data_import_spec.rb
require 'rails_helper'

RSpec.describe SpreadsheetDataImport, type: :service do
  let(:spreadsheet_url) do
    # spreadsheet url https://docs.google.com/spreadsheets/d/1jAH2DRKhwwr70gb73Lq914tNy9YgidjFoy3SW2Q7TbY/edit?gid=0#gid=0
    # is test data
    "https://docs.google.com/spreadsheets/d/1jAH2DRKhwwr70gb73Lq914tNy9YgidjFoy3SW2Q7TbY/export?format=xlsx"
  end
  let(:service) { described_class.new(spreadsheet_url) }

  before do
    require 'roo'
    spreadsheet = Roo::Spreadsheet.open(spreadsheet_url, extension: :xlsx)
    sheet = spreadsheet.sheet(0)

    User.destroy_all
    TimeOffRequest.destroy_all
  end

  describe "#call" do
    context "when the spreadsheet is valid" do
      it "creates users and time off requests correctly" do
        expect { service.call }.to change(User, :count).by(7).and change(TimeOffRequest, :count).by(4)

        user1 = User.find_by(name: "Wendy Williams")
        user2 = User.find_by(name: "Mark Lopez")
        p User.count

        expect(user1).to be_present
        expect(user2).to be_present

        time_off_request = TimeOffRequest.find_by(user_id: user1.id)
        expect(time_off_request).to be_present
        expect(time_off_request.request_type).to eq("incapacity")
        expect(time_off_request.status).to eq("rejected")
      end
    end

    context "when there is an error in the creation of records" do
      it "does not create any record if the transaction fails" do
        allow(User).to receive(:create_with).and_raise(ActiveRecord::RecordInvalid)

        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
                               .and change(User, :count).by(0)
                               .and change(TimeOffRequest, :count).by(0)
      end
    end
  end
end
