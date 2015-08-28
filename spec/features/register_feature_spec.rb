require 'spec_helper'

feature "user registers", { js: true, vcr: true } do
  background { visit register_path }

  context "when user enters valid personal information" do
    background { fill_in_personal_info(valid: true) }

    context "when the user enters valid cc information" do
      scenario "the user's card is accepted" do
        fill_in_credit_info_and_submit(accepted: true)
        expect(page).to have_content "You have successfully registered!"
      end

      scenario "the user's card is declined, expired, etc." do
        fill_in_credit_info_and_submit(declined: true)
        expect(page).to have_content 'declined'
      end
    end

    scenario "the user enters invalid cc information" do
      fill_in_credit_info_and_submit(invalid: true)
      expect(page).to have_content('looks invalid')
    end
  end

  context "when the user enters invalid personal information" do
    background { fill_in_personal_info(valid: false) }

    scenario "the user enters invalid credit card information" do
      fill_in_credit_info_and_submit(invalid: true)
      expect(page).to have_content('looks invalid')
    end

    scenario "the user enters valid credit card information" do
      fill_in_credit_info_and_submit(accepted: true)
      expect(page).to have_content("doesn't match")
    end

    scenario "the user enters a card that would be declined" do
      fill_in_credit_info_and_submit(declined: true)
      expect(page).to have_content("doesn't match")
    end
  end

  def fill_in_personal_info(valid:)
    fill_in "Email Address", with: "foo@bar.com"
    fill_in "Password", with: 'password'
    if valid
      fill_in "Confirm Password", with: 'password'
    else
      fill_in "Confirm Password", with: 'pword'
    end
    fill_in "Full Name", with: "Alice"
  end

  def fill_in_credit_info_and_submit(invalid: false, accepted: false, declined: false)
    cc_number = '4242424242424242' if accepted
    cc_number = '4000000000000002' if declined
    cc_number = '' if invalid
    fill_in "Credit Card Number", with: cc_number
    fill_in "Security Code", with: '123'
    select "7 - July", from: 'exp-month'
    select "2018", from: 'exp-year'
    click_button 'Sign Up'
  end
end
