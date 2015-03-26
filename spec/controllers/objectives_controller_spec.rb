require 'rails_helper'

RSpec.describe ObjectivesController, :type => :controller do

  describe 'GET index' do 
    before(:all) do
      Objective.delete_all
      @objectiveone = create(:objective)
      @objectivetwo = create(:objective)
      @objectivethree = create(:objective)
    end

    it 'loads an array of objective hashes by most recently created' do
      get :index
      expect(assigns(:objectives)).to eq [
        {id: @objectivethree.id, name: @objectivethree.name, description: @objectivethree.description, targetgoal: @objectivethree.targetgoal, progress: @objectivethree.progress},
        {id: @objectivetwo.id, name: @objectivetwo.name, description: @objectivetwo.description, targetgoal: @objectivetwo.targetgoal, progress: @objectivetwo.progress},
        {id: @objectiveone.id, name: @objectiveone.name, description: @objectiveone.description, targetgoal: @objectiveone.targetgoal, progress: @objectiveone.progress} 
      ]
    end

    it 'loads a list of objectives when using JSON' do
      get :index, format: :json
      expect(response.body).to eq [
        {id: @objectivethree.id, name: @objectivethree.name, description: @objectivethree.description, targetgoal: @objectivethree.targetgoal, progress: @objectivethree.progress},
        {id: @objectivetwo.id, name: @objectivetwo.name, description: @objectivetwo.description, targetgoal: @objectivetwo.targetgoal, progress: @objectivetwo.progress},
        {id: @objectiveone.id, name: @objectiveone.name, description: @objectiveone.description, targetgoal: @objectiveone.targetgoal, progress: @objectiveone.progress}
      ].to_json
    end

    it 'renders the index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET show' do
    before(:each) do
      @objective = create(:objective)
      get :show, id: @objective, format: :html
    end

    it 'assigns @objective with the corresponding object to the id' do
      expect(assigns(:objective)).to eq @objective
    end

    it 'renders a show template' do
      expect(response).to render_template :show
    end
  end

  describe 'GET new' do
    before(:each) do
      get :new
    end
    it 'assigns a new Objective to @objective' do
      expect(assigns(:objective)).to be_a_new(Objective)
    end

    it 'renders a new template' do
      expect(response).to render_template :new
    end
  end

  describe 'POST create' do
    it 'creates a new objective' do
      expect{post :create, objective: attributes_for(:objective)}.to change{Objective.all.count}.by(1)
    end

    it 'redirects to objectives path on success when using html' do
      post :create, objective: attributes_for(:objective), format: :html
      expect(response).to redirect_to objectives_path
    end

    it 'redirects to new objectives path on failure when using html' do
      post :create, objective: attributes_for(:objective, name: nil), format: :html
      expect(response).to redirect_to new_objective_path
    end

    it 'responds with a success status on success when using json' do
      post :create, objective: attributes_for(:objective), format: :json
      expect(response).to have_http_status(:success)
    end

    it 'responds with a unprocessable entity status on failure when using json' do
      post :create, objective: attributes_for(:objective, name: nil), format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe 'DELETE destroy' do
    before(:each) do
      @objective = create(:objective)
    end

    it 'deletes an objective' do
      expect{delete :destroy, id: @objective}.to change{Objective.all.count}.by(-1)
    end

    it 'redirects to objectives path on success when using html' do
      delete :destroy, id: @objective, format: :html
      expect(response).to redirect_to objectives_path
    end

    it 'responds with a success status on success when using json' do
      delete :destroy, id: @objective, format: :json
      expect(response).to have_http_status(:success)
    end
  end

end
