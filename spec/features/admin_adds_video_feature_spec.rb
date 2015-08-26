require 'spec_helper'

feature "admin adds video" do
  background do
    category = Fabricate(:category, title: 'hey')
    sign_in_admin
    visit new_admin_video_path
  end

  scenario "admin adds video, user can view it" do
    complete_and_submit_video_form
    expect_success_message
    sign_out

    expect_video_visible_on_home_page

    expect_large_image_on_video_page
    expect_video_watchable
  end

  def complete_and_submit_video_form
    fill_in "Title", with: "Video Title"
    fill_in "Description", with: "Super cool, big fun."
    select 'hey', from: "Category"
    attach_file "Small cover", "#{Rails.root}/public/tmp/monk.jpg"
    attach_file "Large cover", "#{Rails.root}/public/tmp/monk_large.jpg"
    fill_in "Video url", with: 'https://example.com/peter_pan.mp4'
    click_button "Add Video"
  end

  def expect_success_message
    expect(page).to have_content "Video Title has been created."
  end

  def expect_video_visible_on_home_page
    sign_in_user
    expect(page).to have_css('img[src*="monk.jpg"]')
  end

  def expect_large_image_on_video_page
    click_video_link(Video.first)
    expect(page).to have_content "Video Title"
    have_css('img[src*="monk_large.jpg"]')
  end

  def expect_video_watchable
    expect(page).to have_link("Watch Now", href: "https://example.com/peter_pan.mp4")
  end
end
