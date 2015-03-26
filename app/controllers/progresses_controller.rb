class ProgressesController < ApplicationController
  before_filter :find_objective

  def index
    @progresses = Progress.progress_history(@objective)

    respond_to do |format|
      format.html
      format.json { render json: @progresses.to_json }
    end
  end

  def new
    @progress = @objective.progresses.build
  end

  def create
    @progress = @objective.progresses.build(progress_params)
    
    if @progress.save
      redirect_to objective_path(@objective)
    else
      redirect_to new_objective_progress_path(@objective)
    end
  end

  private

  def find_objective
    @objective = Objective.find(params[:objective_id])
  end

  def progress_params
    params.require(:progress).permit(:amount, :objective_id)
  end
end
