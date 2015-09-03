require 'spec_helper'

describe VideoDecorator do
  describe "#display_ratings" do
    let(:video) { Fabricate(:video) }
    subject(:decorator) { video.decorate.average_rating }

    it "should return nil if there are not any reviews" do
      expect(decorator).to be_nil
    end

    it "should return the average rating span if there are any reviews" do
      Fabricate(:review, rating: 5, video: video)
      Fabricate(:review, rating: 4, video: video)

      expect(decorator).to eq("Rating: 4.5 / 5.0")
    end
  end
end
