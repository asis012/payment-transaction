## Problem

You're an engineer for a company that runs a very simple banking service. Each day customer companies provide you with a CSV file with transactions they want to make between accounts for customers they are doing business with. Accounts are identified by a 16 digit number and money cannot be transferred from the account if it will put the balance below zero.

Your job is to implement a simple system that can load starting balances for a list of accounts from a CSV file. It then accepts a list of account transactions in a different CSV file and reports the account balances after the transactions have been processed.

## Getting Started

Use `make run` to execute the cli with the default data. There is a data/ directory with more example scenarios.

```
❯ make run
bundle exec ruby lib/cli.rb ./data/default/accounts.csv ./data/default/transactions.csv
```

Use `make test` to run all tests.


```
❯ make test
bundle exec rspec
```

Use `make lint` to check code for style issues.

```
❯ make lint
bundle exec standardrb lib spec
```

