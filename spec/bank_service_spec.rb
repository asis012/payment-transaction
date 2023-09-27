require "tempfile"

require "./lib/bank_service"

RSpec.describe BankService do
  subject(:bank_service) { described_class.new }

  it "is ready for code challenge candidate" do
    expect(bank_service.run(["transactions.csv"])).to eq("invalid number of arguments")
  end

  describe "#load_account_infos" do
    it "loads account information from a CSV file" do
      bank_service.instance_variable_set(:@account_csv, "./data/default/accounts.csv")

      error = bank_service.load_account_infos
      expect(error).to eq("")
      expect(bank_service.account_infos).to eq({
        "1111234522226789" => "5000.0",
        "1111234522221234" => "10000.0",
        "2222123433331212" => "550.0",
        "1212343433335665" => "1200.0",
        "3212343433335755" => "50000.0"
      })
    end

    it "handles errors when loading account information" do
      allow(CSV).to receive(:foreach).and_raise("CSV Error")

      bank_service.instance_variable_set(:@account_csv, "./data/accounts.csv")

      error = bank_service.load_account_infos
      expect(error).to include("Unable to load account infos from csv. error:")
      expect(bank_service.account_infos).to eq({})
    end
  end

  describe "#initiate_transactions" do
    it "processes transactions from a CSV file" do
      csv_data = "1111234522226789,1212343433335665,100"
      allow(CSV).to receive(:foreach).with(any_args).and_yield(csv_data.split(","))

      bank_service.instance_variable_set(:@account_csv, "transactions.csv")
      bank_service.account_infos = {
        "1111234522226789" => "5000.0",
        "1212343433335665" => "1200.0"
      }

      error = bank_service.initiate_transactions
      expect(error).to eq("")
      expect(bank_service.transaction_infos[0][:from]).to eq("1111234522226789")
      expect(bank_service.transaction_infos[0][:to]).to eq("1212343433335665")
      expect(bank_service.transaction_infos[0][:amount]).to eq("100.0")
      expect(bank_service.transaction_infos[0][:status]).to eq("success")
    end

    it "handles errors when initiating transactions" do
      allow(CSV).to receive(:foreach).and_raise("CSV Error")
      bank_service.instance_variable_set(:@transaction_csv, "transactions.csv")
      error = bank_service.initiate_transactions
      expect(error).to include("Unable to initiate transactions from csv. error:")
      expect(bank_service.transaction_infos).to eq([])
    end
  end
end
