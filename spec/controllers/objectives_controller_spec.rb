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
        {id: @objectivethree.id, name: @objectivethree.name, description: @objectivethree.description, targetgoal: @objectivethree.targetgoal, progress: @objectivethree.progress, created_at: @objectivethree.created_at.to_s, updated_at: @objectivethree.updated_at.to_s},
        {id: @objectivetwo.id, name: @objectivetwo.name, description: @objectivetwo.description, targetgoal: @objectivetwo.targetgoal, progress: @objectivetwo.progress, created_at: @objectivetwo.created_at.to_s, updated_at: @objectivetwo.updated_at.to_s},
        {id: @objectiveone.id, name: @objectiveone.name, description: @objectiveone.description, targetgoal: @objectiveone.targetgoal, progress: @objectiveone.progress, created_at: @objectiveone.created_at.to_s, updated_at: @objectiveone.updated_at.to_s} 
      ]
    end

    it 'renders the index json view using json' do
      get :index, format: :json
      expect(response).to render_template 'objectives/json/index.json.erb'
    end

    it 'renders the index view using html' do
      get :index, format: :html
      expect(response).to render_template :index
    end
  end

  describe 'GET show' do
    before(:each) do
      @objective = create(:objective)
    end

    it 'assigns @objective with the corresponding object to the id' do
      get :show, id: @objective, format: :html
      expect(assigns(:objective)).to eq @objective
    end

    it 'assigns @progress with all progress in recent order associated to the id' do
      progress1 = create(:progress, objective: @objective)
      progress2 = create(:progress, objective: @objective)

      get :show, id: @objective, format: :html
      expect(assigns(:progress)).to eq [
        {id: progress2.id, amount: progress2.amount, created_at: progress2.created_at.to_s},
        {id: progress1.id, amount: progress1.amount, created_at: progress1.created_at.to_s}
      ]
    end

    it 'renders a show template' do
      get :show, id: @objective, format: :html
      expect(response).to render_template :show
    end

    it 'responds with a status of success on success when using json' do
      get :show, id: @objective, format: :json
      expect(response).to have_http_status(:success)
    end

    it 'renders show.json.erb template when using json' do
      get :show, id: @objective, format: :json
      expect(response).to render_template 'objectives/json/show.json.erb'      
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
      @objective = create(:objective, :with_progress)
    end

    it 'deletes an objective' do
      expect{delete :destroy, id: @objective}.to change{Objective.all.count}.by(-1)
    end

    it 'deletes all corresponding progress when the related objective is deleted' do
      progressids = Array.new
      @objective.progresses.each do |p|
        progressids << p.id
      end

      expect{delete :destroy, id: @objective}.to change{Progress.where(id: progressids).count}.to(0)
    end

    it 'redirects to objectives path on success when using html' do
      delete :destroy, id: @objective, format: :html
      expect(response).to redirect_to objectives_path
    end

    it 'responds with a an @objective object in json when using json' do
      delete :destroy, id: @objective, format: :json
      expect(response.body).to eq @objective.to_json
    end

    it 'responds with a success status on success when using json' do
      delete :destroy, id: @objective, format: :json
      expect(response).to have_http_status(:success)
    end
  end

end
