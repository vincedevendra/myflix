require 'spec_helper'

feature "Signing in" do
  given(:user) { Fabricate(:user) }

  scenario "Signing in with the correct credentials" do
    visit sign_in_path
    fill_in "Email Address", with: user.email
    fill_in "Password", with: 'password'
    click_button 'Sign In'

    expect(page).to have_content user.full_name
  end
end