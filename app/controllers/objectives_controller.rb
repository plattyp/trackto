class ObjectivesController < ApplicationController

  def index
    @objectives = Objective.recent_objectives_with_progress

    respond_to do |format|
      format.html
      format.json { render json: @objectives.to_json }
    end
  end

  def show
    @objective = Objective.find(params[:id])
  end

  def new
    @objective = Objective.new
  end

  def create
    @objective = Objective.new(objective_params)
    respond_to do |format|
      if @objective.save
        format.html { redirect_to objectives_path, notice: 'Objective was successfully created!' }
        format.json { render json: @objective.to_json, status: 200 }
      else
        format.html { redirect_to new_objective_path, notice: 'Objective was unable to be created' }
        format.json { render json: @objective.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @objective = Objective.find(params[:id])
    @objective.destroy

    respond_to do |format|
      if @objective.destroyed?
        format.html { redirect_to objectives_path, notice: 'Objective was successfully deleted!' }
        format.json { head :ok, status: 200 }
      else
        format.html { redirect_to objectives_path, notice: 'Objective was unable to be deleted' }
        format.json { render @objective.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def objective_params
    params.require(:objective).permit(:name,:description,:targetgoal)
  end
end
