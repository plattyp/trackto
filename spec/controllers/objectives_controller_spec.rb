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

    it 'renders the index view' do
      get :index
      expect(response).to render_template :index
    end
  end

end
