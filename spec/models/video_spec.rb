require 'spec_helper.rb'

describe Video do
  it { should belong_to(:category) }
  it { should have_many(:reviews).order('created_at DESC') }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

  describe '#search_by_title' do
    it "returns an empty array if there are no matches" do
      firefly = Video.create(title: "Firefly", description: 'show')
      firefly2 = Video.create(title: "Firefly 2", description: 'show')
      fireflys = Video.create(title: "The Firefly Show", description: 'show')
      muppets = Video.create(title: "Muppet Babies", description: 'show')
      expect(Video.search_by_title('finekerdoo')).to eq([])
    end

    it "returns an array of one videos whose titles match exactly and where there's no other partial matches" do
      firefly = Video.create(title: "Firefly", description: 'show')
      firefly2 = Video.create(title: "Firefly 2", description: 'show')
      fireflys = Video.create(title: "The Firefly Show", description: 'show')
      muppets = Video.create(title: "Muppet Babies", description: 'show')
      expect(Video.search_by_title('Muppet Babies')).to eq([muppets])
    end

    it "retuns an array of videos that have a full word match (ordered by created at)" do
      firefly = Video.create(title: "Firefly", description: 'show')
      firefly2 = Video.create(title: "Firefly 2", description: 'show')
      fireflys = Video.create(title: "The Firefly Show", description: 'show')
      muppets = Video.create(title: "Muppet Babies", description: 'show')
      expect(Video.search_by_title('Firefly')).to eq([fireflys, firefly2, firefly])
    end


    it "retuns an array of videos that are partial matches (ordered by created at)" do
      firefly = Video.create(title: "Firefly", description: 'show')
      firefly2 = Video.create(title: "Firefly 2", description: 'show')
      fireflys = Video.create(title: "The Firefly Show", description: 'show')
      muppets = Video.create(title: "Muppet Babies", description: 'show')
      expect(Video.search_by_title('iref')).to eq([fireflys, firefly2, firefly])
    end

    it "returns a blank array if the search terms are blank" do
      firefly = Video.create(title: "Firefly", description: 'show')
      firefly2 = Video.create(title: "Firefly 2", description: 'show')
      fireflys = Video.create(title: "The Firefly Show", description: 'show')
      muppets = Video.create(title: "Muppet Babies", description: 'show')
      expect(Video.search_by_title('')).to eq([])
    end

    it "is case insensitive" do
      firefly = Video.create(title: "Firefly", description: 'show')
      expect(Video.search_by_title('firefly')).to eq([firefly])
    end
  end

  describe "#average_rating" do
    let(:alpha) { Fabricate(:video) }
    before { Fabricate(:review, video: alpha, rating: 4) }

    it "if there is one rating (n), it returns n.0" do
       expect(alpha.average_rating).to eq(4.0)
    end

    it "returns the average rating if there is more than one review" do
      Fabricate(:review, video: alpha, rating: 5)
      expect(alpha.average_rating).to eq(4.5)
    end

    it "rounds the average rating to the nearest tenth" do
      Fabricate(:review, video: alpha, rating: 5)
      Fabricate(:review, video: alpha, rating: 4)
      expect(alpha.average_rating).to eq(4.3)
    end
  end

  describe ".search", :elasticsearch do
    let(:refresh_index) do
      Video.import
      Video.__elasticsearch__.refresh_index!
    end

    context "with title" do
      it "returns no results when there's no match" do
        Fabricate(:video, title: "Futurama")
        refresh_index

        expect(Video.search("whatever").records.to_a).to eq []
      end

      it "returns an empty array when there's no search term" do
        futurama = Fabricate(:video)
        south_park = Fabricate(:video)
        refresh_index

        expect(Video.search("").records.to_a).to eq []
      end

      it "returns an array of 1 video for title case insensitve match" do
        futurama = Fabricate(:video, title: "Futurama")
        south_park = Fabricate(:video, title: "South Park")
        refresh_index

        expect(Video.search("futurama").records.to_a).to eq [futurama]
      end

      it "returns an array of many videos for title match" do
        star_trek = Fabricate(:video, title: "Star Trek")
        star_wars = Fabricate(:video, title: "Star Wars")
        refresh_index

        expect(Video.search("star").records.to_a).to match_array [star_trek, star_wars]
      end
    end

    context "with title and description" do
      it "returns an array of many videos based for title and description match" do
        star_wars = Fabricate(:video, title: "Star Wars")
        about_sun = Fabricate(:video, description: "sun is a star")
        refresh_index

        expect(Video.search("star").records.to_a).to match_array [star_wars, about_sun]
      end
    end

    context "multiple words must match" do
      it "returns an array of videos where 2 words match title" do
        star_wars_1 = Fabricate(:video, title: "Star Wars: Episode 1")
        star_wars_2 = Fabricate(:video, title: "Star Wars: Episode 2")
        bride_wars = Fabricate(:video, title: "Bride Wars")
        star_trek = Fabricate(:video, title: "Star Trek")
        refresh_index

        expect(Video.search("Star Wars").records.to_a).to match_array [star_wars_1, star_wars_2]
      end
    end
  end
end
