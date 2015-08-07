require 'spec_helper'

describe QueueItem do
  it { should belong_to(:user) }
  it { should belong_to(:video) }
  it { should validate_uniqueness_of(:position).scoped_to(:user_id) }
  it { should validate_uniqueness_of(:video_id).scoped_to(:user_id) }

  let(:user) { Fabricate(:user) }
  let(:category) { Fabricate(:category, title: "Good Shows") }
  let(:video) { Fabricate(:video, title: "Arrested Development", category: category) }
  let!(:q) { QueueItem.create(position: 1, user: user, video: video) }
    
  describe "#user_rating" do

    it "returns the rating the user has given in her/his review of the video" do
      review = Fabricate(:review, user: user, video: video)
      expect(q.user_rating).to eq(review.rating) 
    end

    it "returns nil if the user hasn't rated the video" do
      expect(q.user_rating).to be_nil
    end
  end

  describe "#video_title" do
    it "returns the title of the associated video" do
      expect(q.video_title).to eq("Arrested Development")
    end
  end

  describe "#category_title" do
    it "should return the title of the category of the associated video" do
      expect(q.category_title).to eq("Good Shows")
    end
  end

  describe "#category" do
    it "should return the category of the associated video" do
      expect(q.category).to eq(category)
    end
  end

  describe "#update_queue_position_numbers" do
    let!(:q2) { QueueItem.create(position: 2, user: user, video: Fabricate(:video)) }
    let!(:q3) { QueueItem.create(position: 3, user: user, video: Fabricate(:video)) }
    let!(:q4) { QueueItem.create(position: 2, user: Fabricate(:user), video: video) }
    
    it "lowers the position number of every item in a user's queue that is 
        higher than the deleted position by one" do
      deleted = q2.destroy
      deleted.update_queue_position_numbers
      expect(q3.reload.position).to eq(2)
    end

    it "leaves alone unaffected queue items" do
      q.update_queue_position_numbers
      expect(q4.reload.position).to eq(2)
      expect(q.reload.position).to eq(1)
    end
  end
end