require 'spec_helper'

describe User do
  it { should have_many(:reviews) }
  it { should have_one(:queue_item) }
end