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
