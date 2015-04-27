require 'rails_helper'
require 'json'

RSpec.describe RegistrationsController, type: :controller do
  before(:each) do
    User.delete_all

    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.env["HTTP_ACCEPT"] = "application/json"
    @request.env["CONTENT_TYPE"] = "application/json"
  end
 
  it "creates an account" do
    req = dummy_registration
    post :create, req
 
    content = req[:user]
 
    login = User.first
    expect(login).not_to be_nil
    expect(login.email).to eq(content[:email])
    expect(login.password).to eq(login.password_confirmation)
    expect(login.authentication_token).not_to be_nil
    expect(login.created_at).to be < Time.now
  end

  it "does not create a duplicate account" do
    post :create, dummy_registration, format: :json
    expect{post :create, dummy_registration, format: :json}.not_to change{User.all.count}
  end
 
  it "validates email format" do
    wrong_req = dummy_registration
    wrong_req[:user][:email] = "wrong_email"
    post :create, wrong_req
 
    wrong_req = dummy_registration
    wrong_req[:user][:email] = "wrong_email@"
    post :create, wrong_req
 
    wrong_req = dummy_registration
    wrong_req[:user][:email] = "wrong_email@a."
    post :create, wrong_req
 
    users = User.all
    expect(users.count).to be_zero
  end

  it "validates presence of email" do
    wrong_req = dummy_registration
    wrong_req[:user][:email] = nil
    post :create, wrong_req
 
    users = User.all
    expect(users.count).to be_zero
  end
end
