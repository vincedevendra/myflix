shared_examples "no_current_user_redirect" do 
  before do
    clear_current_user
    action
  end

  it "should redirect to welcome path" do
    expect(response).to redirect_to welcome_path
  end
end