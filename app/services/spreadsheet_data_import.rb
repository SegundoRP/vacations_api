require 'roo'

class SpreadsheetDataImport
  def initialize(spreadsheet_url)
    @spreadsheet_url = spreadsheet_url
  end

  def call
    sheet = Roo::Spreadsheet.open(spreadsheet_url, extension: :xlsx).sheet(0)

    Rails.logger.info "Inicializando importación de datos..."

    ActiveRecord::Base.transaction do
      (2..sheet.last_row).each do |row|
        leader = create_leader(sheet, row)
        employee = create_employee(leader, sheet, row)
        update_leader(sheet, row)
        create_time_off_request(employee, sheet, row)
      end
    end

    Rails.logger.info "Datos importados exitosamente."
  end

  private

  attr_reader :spreadsheet_url

  def create_employee(leader, sheet_file, row)
    User.create_with(
      name: sheet_file.row(row)[1],
      email: sheet_file.row(row)[2],
      password: "password123",
      password_confirmation: "password123",
      leader: leader
    ).find_or_create_by(name: sheet_file.row(row)[1])
  end

  def create_leader(sheet_file, row)
    unless sheet_file.row(row)[3] == "CEO"
      leader = User.find_or_create_by(name: sheet_file.row(row)[3])
      email = "test#{row}@test.com"
      leader.update(position: 'leader', uid: email, email: email) if leader.present?
      leader
    end
  end

  def update_leader(sheet_file, row)
    leader = User.find_by(name: sheet_file.row(row)[1], position: 'leader')

    return if leader.blank?

    leader.update(
      email: sheet_file.row(row)[2],
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def create_time_off_request(employee, sheet_file, row)
    TimeOffRequest.create!(
      user_id: employee.id,
      request_type: sheet_file.row(row)[6] == "Incapacidad" ? "incapacity" : "vacation",
      status: sheet_file.row(row)[8] == "Aprobado" ? "approved" : "rejected",
      start_date: sheet_file.row(row)[4],
      end_date: sheet_file.row(row)[5],
      reason: sheet_file.row(row)[7]
    )
  end
end
