class BankService
  require "csv"
  require "securerandom"
  require "bigdecimal"

  # account_infos is a hash with account number and balance
  # transaction_infos is aa array of has with different transaction infos with transactionIDs
  attr_accessor :account_infos
  attr_accessor :transaction_infos

  def initialize
    @account_infos = {}
    @transaction_infos = []
  end

  def run(args)
    if args.length != 2
      return "invalid number of arguments"
    end

    @account_csv = args[0]
    @transaction_csv = args[1]

    error = load_account_infos
    return "Error: #{error}" unless error == ""
    error = initiate_transactions
    return "Error: #{error}" unless error == ""

    puts "Transaction infos that took place"
    puts @transaction_infos

    puts "------------------------------"
    puts "Account infos after transaction has been completed"
    puts @account_infos
  end

  # load account info according to .csv
  def load_account_infos
    begin
      CSV.foreach(@account_csv, headers: true, encoding: "iso-8859-1:utf-8") do |row|
        account_number, balance = row[0], row[1]
        next if @account_infos.has_key?(account_number)
        @account_infos[account_number] = format_amount_for_db(balance)
      end
    rescue => e
      error = "Unable to load account infos from csv. error: #{e.message}"
      return error
    end
    ""
  end

  # initiate_transactions according to .csv
  def initiate_transactions
    begin
      CSV.foreach(@transaction_csv, headers: true, encoding: "iso-8859-1:utf-8") do |row|
        transaction_from, transaction_to, transaction_amount = row[0], row[1], format_amount(row[2])

        validation_error = validate_transaction(transaction_from, transaction_to, transaction_amount)
        if validation_error.length != 0
          transaction = generate_transaction_resp(transaction_from, transaction_to, transaction_amount, "error", validation_error)
          @transaction_infos.append(transaction)
          next
        end
        process_transaction(transaction_from, transaction_to, transaction_amount)
      end
    rescue => e
      return "Unable to initiate transactions from csv. error: #{e}"
    end
    ""
  end

  private

  # generate unique transaction id for reference
  def generate_transaction_id(account_from, account_to)
    timestamp = Time.now.strftime("%Y%m%d%H%M%S") # Format: YYYYMMDDHHMMSS
    unique_id = SecureRandom.hex(4) # Generate a random 4-byte hexadecimal string
    "#{timestamp}-#{unique_id}-#{account_from[-4..]}-#{account_to[-4..]}"
  end

  # validate transaction before processing
  def validate_transaction(transaction_from, transaction_to, transaction_amount)
    error = []
    unless @account_infos.has_key?(transaction_from)
      error.append("invalid info of sender")
    end
    unless @account_infos.has_key?(transaction_to)
      error.append("invalid info of receiver")
    end
    unless transaction_amount >= format_amount(0)
      error.append("transaction amount is less than zero")
    end
    if @account_infos[transaction_from] && format_amount(@account_infos[transaction_from]) < transaction_amount
      error.append("transaction amount is greater than sender balance")
    end
    error
  end

  # process the transaction
  def process_transaction(transaction_from, transaction_to, transaction_amount)
    @account_infos[transaction_from] = format_amount_for_db(format_amount(@account_infos[transaction_from]) - transaction_amount)
    @account_infos[transaction_to] = format_amount_for_db(format_amount(@account_infos[transaction_to]) + transaction_amount)
    transaction = generate_transaction_resp(transaction_from, transaction_to, transaction_amount, "success")
    @transaction_infos.append(transaction)
  end

  def generate_transaction_resp(transaction_from, transaction_to, transaction_amount, status, error = "")
    transaction_id = generate_transaction_id(transaction_from, transaction_to)
    transaction = {
      id: transaction_id,
      from: transaction_from,
      to: transaction_to,
      amount: format_amount_for_db(transaction_amount),
      status: status
    }
    transaction["error"] = error unless error == ""
    transaction
  end

  def format_amount(amount)
    BigDecimal(amount)
  end

  def format_amount_for_db(amount)
    BigDecimal(amount).truncate(6).to_s("F")
  end
end
