require 'spec_helper'

describe User do
  it { should have_many(:reviews) }
  it { should have_many(:queue_items) }
end

describe "#has_video_in_queue?" do
    let(:pete) { Fabricate(:user) }
    let(:video) { Fabricate(:video) }
    subject { pete.has_video_in_queue?(video) }

    it "returns true if the video is in the user's queue" do
      QueueItem.create(position: 1, user: pete, video: video)
      expect(subject).to eq(true)
    end
      
    it "returns false if the video is not in the current user's queue" do
      expect(subject).to eq(false)
    end
  end

  describe "#video_queue_item" do
      let(:pete) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      subject { pete.video_queue_item(video) }
       
    it "returns the queue_item associated with user and video if it exists" do
      q = QueueItem.create(position: 1, user: pete, video: video)
      expect(subject).to eq(q)
    end

    it "returns nil if there is no queue item associated with user and video" do
      expect(subject).to eq(nil)
    end
  end