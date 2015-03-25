class ObjectivesController < ApplicationController

  def index
    @objectives = Objective.all_objectives

    respond_to do |format|
      format.html
      format.json { render json: @objectives.to_json }
    end
  end

  def create
    objective = Objective.new(objective_params)
    if objective.save
      redirect_to objectives_path
    else
      redirect_to objectives_path
    end
  end

  def destroy
    objective = Objective.find(params[:id])
    if objective.destroy
      redirect_to objectives_path
    else
      redirect_to objectives_path
    end
  end

  private

  def objective_params
    params.require(:objective).permit(:name,:description,:targetgoal)
  end
end
