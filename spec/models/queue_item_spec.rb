require 'spec_helper'

describe QueueItem do
  it { should belong_to(:user) }
  it { should have_many(:videos).through(:queue_videos) }
  it { should validate_presence_of(:user) }
end