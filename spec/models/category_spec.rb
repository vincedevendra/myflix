require 'spec_helper'

describe Category do
  it { should have_many(:videos) }

  describe "#recent_videos" do
    it "returns all videos in the category if there's less than 6." do
      comedies = Category.create(title: "Comedies")
      5.times do |i|
        Video.create(title: "title#{i}", description: 'description', category: comedies)
      end
      expect(comedies.recent_videos).to match_array(comedies.videos.all)
    end

    it "returns all videos in the cat. if there are less than 6, in order, beginning with the most recently created." do
      comedies = Category.create(title: "Comedies")
      v1 = Video.create(title: 't1', description: 'description', category: comedies, created_at: 5.days.ago)
      v2 = Video.create(title: 't2', description: 'description', category: comedies, created_at: 4.days.ago)
      v3 = Video.create(title: 't3', description: 'description', category: comedies, created_at: 3.days.ago)
      v4 = Video.create(title: 't4', description: 'description', category: comedies, created_at: 2.days.ago)
      v5 = Video.create(title: 't5', description: 'description', category: comedies, created_at: 1.days.ago)
      expect(Category.first.recent_videos).to eq([v5, v4, v3, v2, v1])
    end

    it "returns the six most recently created videos in a category if there are more than six, beginning with most recently created." do
      comedies = Category.create(title: "Comedies")
      v1 = Video.create(title: 't1', description: 'description', category: comedies, created_at: 7.days.ago)
      v2 = Video.create(title: 't2', description: 'description', category: comedies, created_at: 6.days.ago)
      v3 = Video.create(title: 't3', description: 'description', category: comedies, created_at: 5.days.ago)
      v4 = Video.create(title: 't4', description: 'description', category: comedies, created_at: 4.days.ago)
      v5 = Video.create(title: 't5', description: 'description', category: comedies, created_at: 3.days.ago)
      v6 = Video.create(title: 't6', description: 'description', category: comedies, created_at: 2.days.ago)
      v7 = Video.create(title: 't7', description: 'description', category: comedies, created_at: 1.days.ago)
      expect(Category.first.recent_videos).to eq([v7, v6, v5, v4, v3, v2])
    end

    it "returns a blank array if a category has no videos" do
      comedies = Category.create(title: "Comedies")
      expect(comedies.recent_videos).to eq([])
    end
  end
end