class SubobjectivesController < ApplicationController
  before_filter :find_objective, except: :add_progress
  before_filter :check_access, only: [:index, :show, :update, :add_progress]

  def index
    @subobjectives = Subobjective.all_subobjectives(@objective)
  end

  def show
    @subobjective = Subobjective.find_by_id(params[:subobjective_id])
  end

  def create
    @subobjective = @objective.subobjectives.build(subobjective_params)

    respond_to do |format|
      if @subobjective.save
        format.json { render json: @subobjective.to_json, status: 200 }
      else
        format.json { render json: @subobjective.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def update
    @subobjective = Subobjective.find(params[:subobjective_id])
    @subobjective.update(subobjective_params)

    respond_to do |format|
      if @subobjective.save
        format.json { render json: @subobjective.to_json, status: 200 }
      else
        format.json { render json: @subobjective.errors.to_json, status: :unprocessable_entity}
      end
    end
  end

  def add_progress
    @subobjective = Subobjective.find(params[:subobjective_id])
    @progress = @subobjective.progresses.new(amount: 1)

    respond_to do |format|
      if @progress.save
        format.json { render json: @progress.to_json, status: 200 }
      else
        @messages = @progress
        format.json { render 'layouts/json/errors.json.erb', status: :unprocessable_entity }
      end
    end
  end

  private

  def subobjective_params
    params.require(:subobjective).permit(:name,:description)
  end

  def find_objective
    @objective = Objective.find(params[:objective_id])
  end

  def check_access
    objective    = Objective.find_by_id(params[:objective_id])
    subobjective = Subobjective.find_by_id(params[:subobjective_id])

    obj = objective || subobjective

    if obj.nil?
      respond_to do |format|
        format.json { render json: {"error": "This objective/subobjective does not exist"}, status: 404, content_type: 'application/json' }
      end
    else
      if obj.user.id != current_user.id
        respond_to do |format|
          format.json { render json: {"error": "You do not have access to this objective/subobjective"}, status: 401, content_type: 'application/json' }
        end
      end
    end
  end
end
