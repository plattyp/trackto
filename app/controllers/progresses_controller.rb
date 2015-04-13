class ProgressesController < ApplicationController
  before_filter :find_objective, except: :all_progress

  def all_progress
    @progresses = Progress.all_progress

    respond_to do |format|
      format.json { render json: @progresses.to_json }
    end
  end

  def index
    @progresses = Progress.progress_history(@objective)

    respond_to do |format|
      format.html
      format.json { render 'progresses/json/index.json.erb', status: 200, content_type: 'application/json' }
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
        format.html { render :new }
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
