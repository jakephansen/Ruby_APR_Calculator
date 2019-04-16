# Written by Jake Hansen, April 2019 
#
# Data Structures
# Accounts Hash
#               0             1         2         3       4           5         6
# card_num => start_date, first_name, last_name, apr, credit_limit, balance, last_updated_date]
#
# Charges Hash
#               0             1
# card_num => [charge date, charge amount ]
#
# Payments Hash
#               0               1
# card_num => [payment date, payment amount ]
require 'date'

def create_account(accounts, cur_card_num)
  puts ("Enter First_Name")
  first_name = gets.strip
  puts("Enter Last_Name")
  last_name = gets.strip
  puts ("Enter APR as 0.XX")
  apr = gets.strip
  puts("Enter Credit_Limit")
  credit_limit = gets.strip
  puts ("Enter 4-digit start date year")
  year = gets.strip
  puts ("Enter start month int ")
  month = gets.strip
  puts ("Enter start day int ")
  day = gets.strip
  puts("Creating Account...")
  input_date = Date.new(year.to_i, month.to_i, day.to_i)
  accounts[cur_card_num] = [input_date, first_name, last_name, apr.to_f,credit_limit.to_i, 0.00, input_date]
  puts("Account Created, Card Number is #{cur_card_num}", cur_card_num)
  cur_card_num = (cur_card_num.to_i + 1).to_s
  return cur_card_num
end

def print_account_info(accounts, card_num)
  if accounts.has_key?(card_num) == true
    output_string = ''
    puts "start_date, first_name, last_name,        apr, credit_limit, balance, last_updated_date"
    for word in accounts[card_num]
      output_string += word.to_s + "        "
    end
    puts output_string
  else
    puts "INVALID ACCOUNT NUMBER"
  end
end

def print_charges_info(charges, card_num)
  if charges.has_key?(card_num) == true
    puts ("Date           amount")
    for transaction in charges[card_num]
        output_string = ""
        output_string += transaction[1][0].to_s
        output_string += "     "
        output_string += transaction[1][1].to_s
        puts output_string
    end
  else
    puts "No Charges for this account "
  end
end

def print_payments_info(payments, card_num)
    if payments.has_key?(card_num)
      puts ("Date           amount")
      for transaction in payments[card_num]
        output_string = ""
        output_string += transaction[1][0].to_s
        output_string += "     "
        output_string += transaction[1][1].to_s
        puts output_string
      end
    else
      puts "No Payments for this account "
    end
end

def print_data(accounts, charges, payments, card_num)
      puts ("--------------------------")
      print ("Account Information for ")
      puts (card_num )
      print_account_info(accounts, card_num)
      puts ("--------------------------")
      print ("Charges History for ")
      puts (card_num)
      print_charges_info(charges, card_num)
      puts ("--------------------------")
      print("Payments History for ")
      puts (card_num)
      print_payments_info(payments, card_num)
end

def display_data(accounts, charges, payments)
    puts ("Please Enter 4-digit card number")
    card_num = gets.strip
    print_data(accounts, charges, payments, card_num)
end

def add_charge(accounts, charges)
    puts "Enter 4-digit Card number, amount, year(XXXX), month, day (values separated by white space)"
    line = gets.strip
    line = line.split
    account_number = line[0]
    charge_amount = line[1]
    year = line[2]
    month = line[3]
    day = line[4]
    charge_date = Date.new(year.to_i, month.to_i, day.to_i)
    addition = [charge_date, charge_amount]
    if charges.has_key?(account_number) == true
      charges[account_number][charges[account_number].length] = addition
    else
      temp = {}
      charges[account_number] = temp
      charges[account_number][0] = addition
    end
    puts "Charge Added!"
end

def add_payment(accounts, payments)
    puts "Enter 4-digit Card number, amount, year(XXXX), month, day (values separated by white space)"
    line = gets.strip
    line = line.split
    card_num = line[0]
    pay_amount = line[1]
    year = line[2]
    month = line[3]
    day = line[4]
    payment_date = Date.new(year.to_i, month.to_i, day.to_i)
    addition = [payment_date, pay_amount]
    if payments.has_key?(card_num) == true
      payments[card_num][payments[card_num].length] = addition
    else
      temp = {}
      payments[card_num] = temp
      payments[card_num][0] = addition
    end
    puts "Payment Added"
end

def input_show_balance(accounts, charges, payments)
  puts "To See balance on specific day for a card, please"
  puts "Enter 4-digit card, 4-digit year, month, day (separated by spaces) "
  line = gets.strip

  # if line.length == 4
    line = line.split
    card_num = line[0]
    year = line[1]
    month = line[2]
    day = line[3]
    display_date = Date.new(year.to_i, month.to_i, day.to_i)
    result = show_balance(accounts, charges, payments, card_num, display_date)
    print ("BALANCE IS " )
    puts (result.round(2))
  # else
  #   puts ("Invalid Input, make sure you don't use commas and include 4 numbers separated by spaces ")
  # end
end

# Calculate interest accured for a 30 day period
def calculate_interest(accounts, charges, payments, card_num, display_date)
    cur_debt = accounts[card_num][5]*-1
    apr_ratio = (accounts[card_num][3]/365.00)
    month_array = Array.new(30, 0)
    #For every thirty days since last update until display date, keep track of charges
    if charges.has_key?(card_num) == true
      for charge in charges[card_num]
        if((charge[1][0] >= accounts[card_num][6]) && (charge[1][0] - accounts[card_num][6] <= 30))
          day = charge[1][0] - accounts[card_num][6]
          month_array[day.to_i] -= charge[1][1].to_i
          accounts[card_num][5] += charge[1][1].to_i
          if(accounts[card_num][5] > accounts[card_num][4])
            puts "The credit limit has been exceded, reject card"
          end
        end
      end
    end
    # For every thirty days since last update until display date, keep track of payments
    if payments.has_key?(card_num) == true
        for payment in payments[card_num]
          if((payment[1][0] >= accounts[card_num][6]) && (payment[1][0] - accounts[card_num][6] <= 30))
            day = payment[1][0] - accounts[card_num][6]
            month_array[day.to_i] += payment[1][1].to_i
            accounts[card_num][5] -= payment[1][1].to_i
          end
      end
    end
    # puts (month_array)
    done = false
    interest = 0.0
    in_counting = false
    cur_counter = 0
    for day in 0..29
      if(month_array[day] == 0)
        interest += apr_ratio*cur_debt
      else
        cur_debt += month_array[day]
        interest += apr_ratio*cur_debt
      end
    end
    accounts[card_num][5] -= interest.round(2)
    accounts[card_num][6] += 30
    return interest.round(2)
end

# Used to calculate balance for time periods < 30 days since the last update
def update_no_interest(accounts, charges, payments, card_num, display_date)
    adder = 0
    if charges.has_key?(card_num) == true
      for charge in charges[card_num]
        if (charge[1][0] >= accounts[card_num][6]) && (charge[1][0] <= display_date)
            adder += charge[1][1].to_i
        end
      end
    end

    if payments.has_key?(card_num) == true
      for payment in payments[card_num]
        if (payment[1][0] >= accounts[card_num][6]) && (payment[1][0] <= display_date)
            adder -= payment[1][1].to_i
        end
      end
    end
    return adder
end

def show_balance(accounts, charges, payments, card_num, display_date)

    if (display_date - accounts[card_num][6] < 30)
        non_interest_days = update_no_interest(accounts, charges, payments, card_num, display_date)
      return accounts[card_num][5] + non_interest_days
    else
      while( display_date - accounts[card_num][6] >= 30)
        calculate_interest(accounts, charges, payments, card_num, display_date)
      end
      non_interest_days = update_no_interest(accounts, charges, payments, card_num, display_date)
      return accounts[card_num][5] + non_interest_days
  end
end

# Data given from the email I recieved specifying the assignment
def input_testing_data(accounts, charges, payments)
  # Test1
  # A customer opens a credit card with a $1,000.00 limit at a 35% APR.
  # The customer charges $500 on opening day (outstanding balance becomes $500).
  # The total outstanding balance owed 30 days after opening should be $514.38.
  # 500 * (0.35 / 365) * 30 = 14.38
  card1 = '1001'
  first_name1 = 'jon'
  last_name1 = 'doe'
  apr1 = 0.35
  credit_limit1 = 1000
  date1 = Date.new(2019, 4, 1)
  charge_date1 = Date.new(2019, 4, 1)
  charge_amount1 = 500
  balance1 = 0
  accounts[card1] = [date1, first_name1, last_name1, apr1, credit_limit1, balance1, date1]
  temp = {}
  temp[0] = [charge_date1, charge_amount1]
  charges[card1] = temp
  # Test 2
  # A customer opens a credit card with a $1,000.00 limit at a 35% APR.
  # The customer charges $500 on opening day (outstanding balance becomes $500).
  # 15 days after opening, the customer pays $200 (outstanding balance becomes $300).
  # 25 days after opening, the customer charges another $100 (outstanding balance becomes $400).
  # The total outstanding balance owed 30 days after opening should be $411.99.
  # (500 * 0.35 / 365 * 15) + (300 * 0.35 / 365 * 10) + (400 * 0.35 / 365 * 5) = 11.99
  card2 = '1002'
  first_name2 = 'jane'
  last_name2 = 'doe'
  apr2 = 0.35
  credit_limit2 = 1000
  date2 = Date.new(2019, 4, 1)
  balance2 = 0
  accounts[card2] = [date2, first_name2, last_name2, apr2, credit_limit2, balance2, date2]
  temp2_charges = {}
  temp2_payments = {}
  temp2_charges[0] = [Date.new(2019, 4, 1), 500]
  temp2_charges[1] = [Date.new(2019, 4, 26), 100]
  temp2_payments[0] = [Date.new(2019, 4, 16), 200]
  charges[card2] = temp2_charges
  payments[card2] = temp2_payments
end


# Main Program
# Set up Testing Data
accounts = {}
charges = {}
payments = {}
cur_card_num = "1003"
input_testing_data(accounts, charges, payments)
x = 1
#Loop for calling all capabilities
while x == 1
  puts ("Please Enter 'Create_Account', 'Add_Payment', 'Add_Charge','Show_Balance', 'Display_Data' or 'Exit'")
  action = gets.strip
  if action == "Create_Account"
    cur_card_num = create_account(accounts, cur_card_num)
  elsif action == "Add_Payment"
    add_payment(accounts, payments)
  elsif action == "Add_Charge"
    add_charge(accounts, charges)
  elsif action == "Show_Balance"
    input_show_balance(accounts, charges, payments)
  elsif action == "Display_Data"
    display_data(accounts, charges, payments)
  elsif action == "Exit"
    break
  else
    puts "Check Your spelling and try again, include underscore and make sure letters are capitalized"
  end
end
puts "Goodbye! :)"
