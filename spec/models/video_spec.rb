require 'spec_helper.rb'

describe Video do
  it { should belong_to(:category) }
  it { should validate_presence_of(:title)}
  it { should validate_presence_of(:description)}

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
end
  