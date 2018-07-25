#!/bin/sh

# APP=salieri

# cd `dirname $0`
# exec erl -smp auto +K true +A 16 -s $APP -pa $PWD/ebin $PWD/lib/*/ebin -sname $APP -config priv/app -boot start_sasl $@
alias Gringotts.{Response, CreditCard, Gateways.Chase}
amount = Money.new(42, :USD)
card = %CreditCard{
   first_name: "Harry",
   last_name: "Potter",
   number: "4200000000000000",
   year: 2099, month: 12,
   verification_code:  "123",
   brand: "VISA"
}
Chase.purchase(amount, card, %{zip: "78757", address1: "123 Pine", address2: nil, city: "Austin", state: "TX", country: "USA", order_number: "123"})


alias Gringotts.{Response, CreditCard, Gateways.Sagepay}
amount = Money.new(42, :USD)
card = %CreditCard{
   first_name: "Harry",
   last_name: "Potter",
   number: "4929000000006",
   year: 2099, month: 12,
   verification_code:  "123",
   brand: "VISA"
}
Sagepay.purchase(amount, card, %{resv_id: "10101012", ip_address: "128.10.0.123", zip: "78757", address1: "123 Pine", address2: nil, city: "London", country: "GB", order_number: "123", issue_number: nil})
