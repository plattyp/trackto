require 'rails_helper'

RSpec.describe ProgressesController, :type => :controller do

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
  end

end
