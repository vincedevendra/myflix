require 'spec_helper'

feature "My Queue" do
  scenario "user adds and reorders videos in the queue" do
    pete = Fabricate(:user)
    category = Fabricate(:category)
    video_1 = Fabricate(:video, category: category)
    video_2 = Fabricate(:video, category: category)
    video_3 = Fabricate(:video, category: category)

    sign_in_user(pete)

    add_video_to_queue(video_1)

    visit_queue_page
    expect_queue_to_have_video(video_1)

    click_video_title_link_from_queue(video_1)
    expect_hide_add_link_show_remove_link

    add_video_to_queue(video_2)
    add_video_to_queue(video_3)
    visit_queue_page
    expect_video_position(video_1, "1", pete)
    expect_video_position(video_2, "2", pete)
    expect_video_position(video_3, "3", pete)

    set_video_position(video_1, "3", pete)
    set_video_position(video_2, "1", pete)
    set_video_position(video_3, "2", pete)
    update_queue

    expect_video_position(video_1, "3", pete)
    expect_video_position(video_2, "1", pete)
    expect_video_position(video_3, "2", pete)
  end

  def add_video_to_queue(video)
    visit root_path
    click_video_link(video)
    click_link "+ My Queue"
  end

  def expect_video_position(video, position, user)
    queue_item = user.video_queue_item(video)
    expect(page).to have_field("queue_items_#{queue_item.id}_position", with: position)
  end

  def set_video_position(video, position, user)
    queue_item = user.video_queue_item(video)
    fill_in "queue_items_#{queue_item.id}_position", with: position
  end

  def click_video_title_link_from_queue(video)
    click_link "#{video.title}"
  end

  def expect_queue_to_have_video(video)
    expect(page).to have_link video.title
  end

  def expect_hide_add_link_show_remove_link
    expect(page).to have_link "X Remove From Queue"
    expect(page).to have_no_link "+ My Queue"
  end

  def update_queue
    click_button "Update Instant Queue"
  end

  def visit_queue_page
    click_link "My Queue"
  end
end
