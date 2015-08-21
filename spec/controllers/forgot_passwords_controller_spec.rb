require 'spec_helper'

describe ForgotPasswordsController do  
  describe "POST create" do
    after { ActionMailer::Base.deliveries.clear }

    context "when the inputted email matches a user's email" do
      let(:alice) { Fabricate(:user)}
      before { post :create, email: alice.email }

      it "creates a token for the user" do
        expect(alice.reload.token).to be_present
      end

      it "sends an email to the user" do
        expect(ActionMailer::Base.deliveries.last.to).to eq([alice.email])
      end

      it "sends an email with a url based on the newly created token" do
        expect(ActionMailer::Base.deliveries.last.body).to include(reset_password_path(alice.reload.token))
      end

      it "redirects_to reset_password_path" do
        expect(response).to redirect_to confirm_password_reset_path
      end
    end

    context "when the inputted email does not match a user's email" do
      before { post :create, email: "test@test.com" }

      it "does not send an email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "sets an error message" do
        expect(flash[:danger]).to be_present
      end

      it "renders 'new' template" do
        expect(response).to render_template 'new'
      end
    end
  end

  describe "GET edit" do
    context "when the token is valid" do
      let!(:alvin) { alvin = Fabricate(:user, token: 'hey') }
      before { get :edit, token: 'hey' }
      
      it "sets @token from the params" do
        expect(assigns(:token)).to eq('hey')
      end

      it "sets @user" do
        expect(assigns(:user)).to eq(alvin)
      end
    end

    context "when the token is invalid" do
      it "redirect_to invalid_token_path" do
        get :edit, token: 'hey'
        expect(response).to redirect_to(invalid_token_path)
      end
    end
  end

  describe "PATCH update" do
    let!(:abby) { Fabricate(:user, token: 'hey') }

    context "when validations pass" do
      before { patch :update, token: 'hey', user: { password: 'foo', password_confirmation: 'foo' } }

      it "updates the user's password" do
        expect(abby.password_digest).not_to eql(abby.reload.password_digest)
      end

      it "clears the user's token" do
        expect(abby.reload.token).to be_nil
      end

      it "flashes an info message" do
        expect(flash[:info]).to be_present
      end

      it "redirect to the sign_in path" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "when the token is invalid" do
      before { patch :update, token: 'hoo', user: { password: 'foo', password_confirmation: 'foo' } }

      it "does not update the user's password" do
        expect(abby.password_digest).to eql(abby.reload.password_digest)
      end

      it "renders 'edit' template" do
        expect(response).to render_template 'edit'
      end 
    end

    context "when validations fail" do
      before { patch :update, token: 'hey', user: { password: 'foo', password_confirmation: 'bar' } }

      it "does not update the user's password" do
        expect(abby.password_digest).to eql(abby.reload.password_digest)
      end

      it "renders the 'edit' template" do
        expect(response).to render_template 'edit'
      end
    end
  end
end