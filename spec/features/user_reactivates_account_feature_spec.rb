require 'spec_helper'

feature "user reactives account", vcr: true, js: true, driver: :selenium do
  background do
    category = Fabricate(:category, title: 'comedies')
    Fabricate(:video, category: category)
  end

  after { ActionMailer::Base.deliveries.clear }

  let(:alice) { Fabricate(:user, stripe_customer_id:
  'cus_6wNhR9Yrp5ITdP') }

  scenario "non-paid user changes credit card information and reactivates account" do
    alice.update_attribute(:valid_subscription, false)
    sign_in_user(alice)
    expect_redirect_to_account_details_page
    click_link "People"
    expect_redirect_to_account_details_page

    click_link "Update Payment Method"
    fill_in_credit_info
    click_button "Submit"
    expect(page).to have_content("changed")

    click_link "Videos"
    expect(page).to have_content('comedies')
  end

  scenario "delinquent user changes credit card information and reactivates account" do
    alice.update_attribute(:delinquent, true)
    sign_in_user(alice)
    expect(page).to have_content "failed payment"

    click_link "My Queue"
    expect(page).to have_content "failed payment"

    click_link "People"
    expect(page).to have_content "failed payment"

    click_link "update your payment method"
    click_link "Update Payment Method"
    fill_in_credit_info
    click_button "Submit"
    expect(page).to have_content("changed")

    click_link "Videos"
    expect(page).not_to have_content "failed payment"
  end

  def expect_redirect_to_account_details_page
    expect(page).to have_content("Account Information")
    expect(page).to have_content("cancelled")
  end

  def fill_in_credit_info
    fill_in "Credit Card Number", with: '4242424242424242'
    fill_in "Security Code", with: '123'
    select "7 - July", from: 'exp-month'
    select "2018", from: 'exp-year'
  end
end
