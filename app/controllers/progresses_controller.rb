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
    
    respond_to do |format|
      if @progress.save
        format.html { redirect_to objective_path(@objective), notice: 'Progress was created successfully!' }
        format.json { render json: @progress.to_json, status: 200 }
      else
        format.html { redirect_to new_objective_progress_path(@objective), notice: 'Progress was unable to be created' }
        format.json { render json: @progress.errors.to_json, status: :unprocessable_entity }
      end
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
