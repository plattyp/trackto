require 'rails_helper'

RSpec.describe ProgressesController, :type => :controller do

  describe 'GET index' do
    before(:each) do
      @objective = create(:objective)
    end

    it 'assigns an empty array to @progresses if there is no progress associated with an objective' do
      get :index, objective_id: @objective.id
      expect(assigns(:progresses)).to eq []
    end

    it 'assigns an all progress by recent order to @progresses if there is progress associated with an objective' do
      progress1 = create(:progress, objective: @objective)
      progress2 = create(:progress, objective: @objective)

      get :index, objective_id: @objective.id
      expect(assigns(:progresses)).to eq [progress2,progress1]
    end

    it 'renders a index template when using html' do
      get :index, objective_id: @objective.id, format: :html
      expect(response).to render_template :index
    end

    it 'renders @progresses when using json' do
      progress1 = create(:progress, objective: @objective)
      progress2 = create(:progress, objective: @objective)

      get :index, objective_id: @objective.id, format: :json
      expect(response.body).to eq [progress2,progress1].to_json
    end
  end

  describe 'GET new' do
    before(:each) do
      @objective = create(:objective)
      get :new, objective_id: @objective.id
    end

    it 'assigns an objective based on the ID parameter' do
      expect(assigns(:objective)).to eq @objective
    end

    it 'assigns a new instance of progress to @progress' do
      expect(assigns(:progress)).to be_a_new(Progress)
    end

    it 'renders a new template' do
      expect(response).to render_template :new
    end
  end
  
  describe 'POST create' do
    before(:each) do
      @objective = create(:objective)
    end

    it 'creates a new progress' do
      expect{post :create, progress: attributes_for(:progress, amount: 10), objective_id: @objective.id}.to change{Progress.all.count}.by(1)
    end

    it 'increases progress for an objective' do
      expect{post :create, progress: attributes_for(:progress, amount: 10), objective_id: @objective.id}.to change{Objective.find(@objective.id).progress}.by(10)
    end

    it 'redirects to objective path on success using html' do
      post :create, progress: attributes_for(:progress, amount:10), objective_id: @objective.id, format: :html
      expect(response).to redirect_to objective_path(@objective)
    end

    it 'redirects to new objective progress path on failure using html' do
      post :create, progress: attributes_for(:progress, amount: nil), objective_id: @objective.id, format: :html
      expect(response).to redirect_to new_objective_progress_path(@objective)
    end

    it 'responds with a status of success on success when using json' do
      post :create, progress: attributes_for(:progress, amount: 10), objective_id: @objective.id, format: :json
      expect(response).to have_http_status(:success)
    end

    it 'responds with a status of unprocessable entity on failure when using json' do
      post :create, progress: attributes_for(:progress, amount: nil), objective_id: @objective.id, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

end
