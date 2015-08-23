require 'spec_helper'

describe User do
  it { should have_many(:reviews) }
  it { should have_many(:queue_items) }
  it { should have_many(:followings).order(created_at: :desc) }
  it { should have_many(:followees).through(:followings) }

  describe "#has_video_in_queue?" do
    let(:pete) { Fabricate(:user) }
    let(:video) { Fabricate(:video) }
    subject { pete.has_video_in_queue?(video) }

    it "returns true if the video is in the user's queue" do
      Fabricate(:queue_item, user: pete, video: video)
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
      queue_item = Fabricate(:queue_item, user: pete, video: video)
      expect(subject).to eq(queue_item)
    end

    it "returns nil if there is no queue item associated with user and video" do
      expect(subject).to eq(nil)
    end
  end

  describe "#follows?(user)" do
    let(:alvin) { Fabricate(:user) }
    let(:betty) { Fabricate(:user) }
    let!(:following) { Fabricate(:following, user: alvin, followee: betty) }

    it "returns true if self follows user" do
      expect(alvin.follows?(betty)).to eq(true)
    end

    it "returns false if self doesn't follow user" do
      expect(betty.follows?(alvin)).to eq(false)
    end
  end

  describe "#following_with(user)" do
    let(:alvin) { Fabricate(:user) }
    let(:betty) { Fabricate(:user) }
    let!(:following) { Fabricate(:following, user: alvin, followee: betty) }

    it "returns the following where self is the follower and user is the followee" do
      expect(alvin.following_with(betty)).to eq(following)
    end
  end

  describe "#follows(followee)" do
    let(:alvin) { Fabricate(:user) }
    let(:bertha) { Fabricate(:user) }
    before { alvin.follows(bertha) }

    it "creates a new following" do
      expect(Following.count).to eq(1)
    end

    it "creates a following with self as the user" do
      expect(Following.first.user).to eq(alvin)
    end

    it "creates a following with followee from arg. as followee" do
      expect(Following.first.followee).to eq(bertha)
    end
  end

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end
end