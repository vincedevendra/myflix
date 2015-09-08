require 'spec_helper'

describe "stripe events handling", :vcr do
  describe "customer creation" do
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

  describe "failed charge" do
    let(:stripe_event) do
      {
        "id" => "evt_16hKYeLBlbbB1VNDcIkdY45f",
        "created" => 1441374528,
        "livemode" => false,
        "type" => "charge.failed",
        "data" => {
          "object" => {
            "id" => "ch_16hKYeLBlbbB1VNDy9RyxtVz",
            "object" => "charge",
            "created" => 1441374528,
            "livemode" => false,
            "paid" => false,
            "status" => "failed",
            "amount" => 999,
            "currency" => "usd",
            "refunded" => false,
            "source" => {
              "id" => "card_16hKWHLBlbbB1VNDSoJofOVE",
              "object" => "card",
              "last4" => "0341",
              "brand" => "Visa",
              "funding" => "credit",
              "exp_month" => 9,
              "exp_year" => 2016,
              "fingerprint" => "VjqcLZolkyVHGS6i",
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
              "customer" => "cus_6uxmf5e2oiEVNI"
            },
            "captured" => false,
            "balance_transaction" => nil,
            "failure_message" => "Your card was declined.",
            "failure_code" => "card_declined",
            "amount_refunded" => 0,
            "customer" => "cus_6uxmf5e2oiEVNI",
            "invoice" => nil,
            "description" => "",
            "dispute" => nil,
            "metadata" => {
            },
            "statement_descriptor" => nil,
            "fraud_details" =>  {
            },
            "receipt_email" =>  nil,
            "receipt_number" =>  nil,
            "shipping" =>  nil,
            "destination" =>  nil,
            "application_fee" =>  nil,
            "refunds" =>  {
              "object" =>  "list",
              "total_count" =>  0,
              "has_more" =>  false,
              "url" =>  "/v1/charges/ch_16hKYeLBlbbB1VNDy9RyxtVz/refunds",
              "data" =>  [
              ]
            }
          }
        },
        "object" => "event",
        "pending_webhooks" => 1,
        "request" => "req_6vAuVFDmxOYj0F",
        "api_version" => "2015-08-19"
      }
    end

    it "sends a warning email to the customer" do
      user = Fabricate(:user, stripe_customer_id: "cus_6uxmf5e2oiEVNI", email: 'foo@bar.com')
      post '/stripe_events', stripe_event
      expect(ActionMailer::Base.deliveries.last.to).to eq(["foo@bar.com"])
      expect(ActionMailer::Base.deliveries.last.body).to include("Your card was declined.")
      ActionMailer::Base.deliveries.clear
    end
  end

  describe "subscription cancellation" do
    let(:stripe_event) do
      {
        "id" => "evt_16hKIHLBlbbB1VNDhDCXeBbQ",
        "created" => 1441373513,
        "livemode" => false,
        "type" => "customer.subscription.deleted",
        "data" => {
          "object" => {
            "id" => "sub_6uxmyuQ7SQMPgs",
            "plan" => {
              "interval" => "month",
              "name" => "Myflix",
              "created" => 1441152821,
              "amount" => 999,
              "currency" => "usd",
              "id" => "myflix_monthly",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil,
              "metadata" => {
              },
              "statement_descriptor" => "myflix"
            },
            "object" => "subscription",
            "start" => 1441325686,
            "status" => "canceled",
            "customer" => "cus_6uxmf5e2oiEVNI",
            "cancel_at_period_end" => false,
            "current_period_start" => 1441325686,
            "current_period_end" => 1443917686,
            "ended_at" => 1441373513,
            "trial_start" => nil,
            "trial_end" => nil,
            "canceled_at" => 1441373513,
            "quantity" => 1,
            "application_fee_percent" => nil,
            "discount" => nil,
            "tax_percent" => nil,
            "metadata" => {
            }
          }
        },
        "object" => "event",
        "pending_webhooks" => 1,
        "request" => "req_6vAd1I9R4HOmYX",
        "api_version" => "2015-08-19"
      }
    end

    it "sets user.valid_subscription to false", :vcr do
      user = Fabricate(:user, stripe_customer_id: "cus_6uxmf5e2oiEVNI")
      post '/stripe_events', stripe_event
      expect(user.reload).not_to be_valid_subscription
      ActionMailer::Base.deliveries.clear
    end

    it "sends a warning email to the customer", :vcr do
      user = Fabricate(:user, stripe_customer_id: "cus_6uxmf5e2oiEVNI", email: 'foo@bar.com')
      post '/stripe_events', stripe_event
      expect(ActionMailer::Base.deliveries.last.to).to eq(["foo@bar.com"])
      expect(ActionMailer::Base.deliveries.last.body).to include("Your subscription has been cancelled")
      ActionMailer::Base.deliveries.clear
    end
  end
end
