require 'spec_helper'

describe QueueVideo do
  it { should belong_to(:video) }
  it { should belong_to(:queue_item) }
end