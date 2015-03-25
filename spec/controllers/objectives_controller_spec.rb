require 'rails_helper'

RSpec.describe ObjectivesController, :type => :controller do

  describe 'GET index' do 
    before(:all) do
      Objective.delete_all
      @objective1 = create(:objective)
      @objective2 = create(:objective)
      @objective3 = create(:objective)
    end

    it 'loads a list of objectives by most recently created' do
      get :index
      expect(assigns(:objectives)).to eq [@objective3, @objective2, @objective1]
    end

    it 'loads a list of objectives to JSON' do
      get :index, :format => :json
      expect(response.body).to eq [@objective3, @objective2, @objective1].to_json
    end

    it 'renders the index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'POST create' do
    it 'creates a new objective' do
      expect{post :create, objective: attributes_for(:objective)}.to change{Objective.all.count}.by(1)
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @objective = create(:objective)
    end
    it 'deletes an objective' do
      expect{delete :destroy, id: @objective}.to change{Objective.all.count}.by(-1)
    end
  end

end
