require 'spec_helper'

feature "invitations", :js, :vcr  do
  given!(:alice) { Fabricate(:user) }

  scenario "user invites a friend" do
    sign_in_user(alice)
    click_link("Welcome")
    click_link("Invite a Friend")

    submit_invitation_form_and_sign_out("Betty", "foo@bar.com")
    open_email_and_click_link("foo@bar.com")
    expect_name_and_email_fields_to_be_filled("Betty", "foo@bar.com")

    submit_register_form('password')
    expect(page).to have_content "You have successfully registered!"

    sign_in_betty
    expect_people_page_to_include(alice)

    click_link "Welcome"
    click_link "Sign Out"
    sign_in_user(alice)
    expect_people_page_to_include(newly_created_user("Betty"))

    clear_emails
  end

  def submit_invitation_form_and_sign_out(name, email)
    fill_in "Friend's Name", with: name
    fill_in "Friend's Email", with: email
    click_button "Send Invitation"
    click_link("Welcome")
    click_link "Sign Out"
  end

  def open_email_and_click_link(email)
    open_email(email)
    current_email.click_link("Join Now!")
  end

  def expect_name_and_email_fields_to_be_filled(name, email)
    expect(page).to have_field "Email", with: email
    expect(page).to have_field "Full Name", with: name
  end

  def submit_register_form(password)
    fill_in "Password", with: password
    fill_in "Confirm Password", with: password
    fill_in "Credit Card Number", with: '4242424242424242'
    fill_in "Security Code", with: '123'
    select "7 - July", from: 'exp-month'
    select "2018", from: 'exp-year'
    click_button "Sign Up"
  end

  def newly_created_user(name)
    User.find_by(full_name: name)
  end

  def sign_in_betty
    visit '/sign_in'
    fill_in "Email Address", with: "foo@bar.com"
    fill_in "Password", with: 'password'
    click_button 'Sign In'
  end

  def expect_people_page_to_include(user)
    click_link "People"
    expect(page).to have_content(user.full_name)
  end
end
