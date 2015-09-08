require 'spec_helper'

describe Admin::PaymentsController do
  describe "get :index" do
    it "sets @payments to all the payments" do
      2.times { Fabricate(:payment) }
      set_admin
      get :index
      expect(assigns(:payments).count).to eq(2)
    end

    it_behaves_like "no admin redirect" do
      let(:action) { get :index}
    end
  end
end
