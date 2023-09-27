default: run

.PHONY: run
run:
	bundle exec ruby lib/cli.rb ./data/default/accounts.csv ./data/default/transactions.csv

.PHONY: lint
lint:
	bundle exec standardrb -a lib spec

.PHONY: test
test:
	bundle exec rspec
