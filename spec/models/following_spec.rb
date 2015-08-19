require 'spec_helper'

describe Following do
  it { should belong_to(:user) }
  it { should belong_to(:followee).class_name("User") }
  it { should validate_uniqueness_of(:followee_id).scoped_to(:user_id) }
end