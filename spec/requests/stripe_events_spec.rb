require 'spec_helper'

describe "stripe events handling", :vcr do
  let(:stripe_event) do
    {
      "id" => "evt_16h0bYLBlbbB1VNDnpcMpBlH",
      "created" => 1441297828,
      "livemode" => false,
      "type" => "charge.succeeded",
      "data" => {
        "object" => {
          "id" => "ch_16h0bYLBlbbB1VNDpQxNnNRs",
          "object" => "charge",
          "created" => 1441297828,
          "livemode" => false,
          "paid" => true,
          "status" => "succeeded",
          "amount" => 999,
          "currency" => "usd",
          "refunded" => false,
          "source" => {
            "id" => "card_16h0bXLBlbbB1VND4ref00zK",
            "object" => "card",
            "last4" => "4242",
            "brand" => "Visa",
            "funding" => "credit",
            "exp_month" => 9,
            "exp_year" => 2018,
            "fingerprint" => "ZsufJSVkv8EGzykH",
            "country" => "US",
            "name" => nil,
            "address_line1" => nil,
            "address_line2" => nil,
            "address_city" => nil,
            "address_state" => nil,
            "address_zip" => nil,
            "address_country" => nil,
            "cvc_check" => "pass",
            "address_line1_check" => nil,
            "address_zip_check" => nil,
            "tokenization_method" => nil,
            "dynamic_last4" => nil,
            "metadata" => {
            },
            "customer" => "cus_6uqIjeW0BRpxzC"
          },
          "captured" => true,
          "balance_transaction" => "txn_16h0bYLBlbbB1VNDVUBAD63t",
          "failure_message" => nil,
          "failure_code" => nil,
          "amount_refunded" => 0,
          "customer" => "cus_6uqIjeW0BRpxzC",
          "invoice" => "in_16h0bYLBlbbB1VNDo5K5Vt1S",
          "description" => nil,
          "dispute" => nil,
          "metadata" => {
          },
          "statement_descriptor" => "myflix",
          "fraud_details" => {
          },
          "receipt_email" => nil,
          "receipt_number" => nil,
          "shipping" => nil,
          "destination" => nil,
          "application_fee" => nil,
          "refunds" => {
            "object" => "list",
            "total_count" => 0,
            "has_more" => false,
            "url" => "/v1/charges/ch_16h0bYLBlbbB1VNDpQxNnNRs/refunds",
            "data" => [

            ]
          }
        }
      }
    }
  end

  let!(:user) { Fabricate(:user, stripe_customer_id: "cus_6uqIjeW0BRpxzC") }

  it "creates a new payment object" do
    post '/stripe_events', stripe_event
    expect(Payment.count).to eq(1)
  end

  it "associates the user with the payment object" do
    post '/stripe_events', stripe_event
    expect(Payment.last.user).to eq(user)
  end

  it "saves the amount of the charge in the payment object" do
    post '/stripe_events', stripe_event
    expect(Payment.last.amount).to eq(999)
  end

  it "saves the charge token on the payment" do
    post '/stripe_events', stripe_event
    expect(Payment.last.token).to eq("ch_16h0bYLBlbbB1VNDpQxNnNRs")
  end
end
