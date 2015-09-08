shared_examples "no_current_user_redirect" do
  before do
    clear_current_user
    action
  end

  it "redirects to welcome path" do
    expect(response).to redirect_to welcome_path
  end
end

shared_examples "tokenable" do
  it "generates a token" do
    object.generate_token!
    expect(object.token).to be_present
  end
end

shared_examples "no admin redirect" do
  before do
    set_current_user
    action
  end

  it "redirects to the root path" do
    expect(response).to redirect_to root_path
  end

  it "sets a danger message" do
    expect(flash[:danger]).to be_present
  end
end

shared_examples "no valid subscription redirect" do
  let(:alice) { Fabricate(:user, valid_subscription: false) }

  before do
    alice.update_attribute(:valid_subscription, false)
    set_current_user(alice)
    action
  end

  it "flashes a danger message" do
    expect(flash[:danger]).to be_present
  end

  it "redirects to the account_details_path" do
    expect(response).to redirect_to account_details_path
  end
end
