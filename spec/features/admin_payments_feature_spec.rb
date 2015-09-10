require 'spec_helper'

feature "admin sees payments" do
  background do
    arnold = Fabricate(:user, email: "foo@bar.org", full_name: "Arnold")
    Fabricate(:payment, user: arnold, token: 'asdfg')
  end

  scenario "user registers, admin sees payment" do
    sign_in_admin
    visit admin_payments_path
    expect(page).to have_content("Arnold")
    expect(page).to have_content("foo@bar.org")
    expect(page).to have_content("asdfg")
  end
end
