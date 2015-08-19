require 'spec_helper'

feature "social networking" do
  given(:betty) { Fabricate(:user) }
  given(:category) { Fabricate(:category) }
  given(:aliens) { Fabricate(:video, category: category) }
  given!(:review) { Fabricate(:review, user: betty, video: aliens)}

  scenario "user follows and unfollows other users" do
    sign_in_user
    click_video_link(aliens)
    click_link(betty.full_name)
    
    click_link("Follow")
    expect(page).to have_content("Unfollow")
    expect(page).to have_content(betty.full_name)

    click_link("Unfollow")
    expect(page).to have_content("Follow")

    click_link("Follow")
    click_link("People")
    expect(page).to have_content(betty.full_name)

    click_remove_link(betty)
    expect(page).to have_selector("#flash_info", text: betty.full_name)
    expect(page).to have_no_selector("tr", text: betty.full_name)
  end

  def click_remove_link(followee)
    click_link(followee.id)
  end
end