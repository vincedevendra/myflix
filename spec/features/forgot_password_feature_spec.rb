require 'spec_helper'

feature "forgot password" do
  given!(:alyosha) { Fabricate(:user, full_name: "Alyosha") }
  
  background do 
    clear_emails
    visit forgot_password_path
  end  

  scenario "user successfully resets password" do
    submit_email_form(alyosha.email)
    open_email_and_follow_link
    submit_password_reset_form("123456")
    submit_sign_in_form_with_new_password("123456")

    expect(page).to have_content "Welcome, Alyosha"
    clear_emails
  end

  scenario "user enters an unknown email address" do
    submit_email_form("foo@bar.com")
    
    expect(page).to have_content "We're having trouble"
  end

  scenario "user tries to use the reset password link twice" do
    submit_email_form(alyosha.email)
    open_email_and_follow_link
    submit_password_reset_form("123456")
    open_email_and_follow_link

    expect(page).to have_content "password link is expired"
    clear_emails
  end

  def submit_email_form(email)
    fill_in "Email Address", with: email
    click_button "Send Email"
  end

  def open_email_and_follow_link
    open_email(alyosha.email)
    current_email.click_link("Reset Password")
  end

  def submit_password_reset_form(password)
    fill_in "New Password", with: password
    fill_in "Confirm New Password", with: password
    click_button "Reset Password"
  end

  def submit_sign_in_form_with_new_password(password)
    fill_in "Email Address", with: alyosha.email
    fill_in "Password", with: password
    click_button "Sign In"
  end
end