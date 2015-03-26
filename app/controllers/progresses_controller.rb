class ProgressesController < ApplicationController

  def new
    @objective = Objective.find(params[:objective_id])
    @progress = @objective.progresses.build
  end

  def create
    @objective = Objective.find(params[:objective_id])
    @progress = @objective.progresses.build(progress_params)
    
    if @progress.save
      redirect_to objective_path(@objective)
    else
      redirect_to new_objective_progress_path(@objective)
    end
  end

  private

  def progress_params
    params.require(:progress).permit(:amount, :objective_id)
  end
end
