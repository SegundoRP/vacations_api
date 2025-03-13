namespace :db do
  desc "Import data from a public Google Sheet"
  task seed_from_google_sheet: :environment do
    url = "https://docs.google.com/spreadsheets/d/1IDC2nJkdY3Z4121a-LR1CIaeWLz4kZ7J628hMTSf_aM/export?format=xlsx"

    SpreadsheetDataImport.new(url).call
  end
end
