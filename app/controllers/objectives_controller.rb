class ObjectivesController < ApplicationController
  #Used temporarily until authentication is put into place
  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }

  def index
    @objectives = Objective.recent_objectives_with_progress

    respond_to do |format|
      format.html
      format.json { render 'objectives/json/index.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def show
    @objective = Objective.find_by_id(params[:id])

    respond_to do |format|
      if !@objective.nil?
        @progress = Progress.progress_history(@objective)

        format.html
        format.json { render 'objectives/json/show.json.erb', status: 200, content_type: 'application/json' }
      else
        format.html { redirect_to objectives_path, alert: 'Objective does not exist' }
        format.json { render json: {"errors": ["Objective does not exist"]}, status: 404, content_type: 'application/json' }
      end
    end
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
        format.html { render :new }
        format.json { render json: @objective.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @objective = Objective.find(params[:id])
    @objective.destroy

    respond_to do |format|
      if @objective.destroyed?
        format.html { redirect_to objectives_path, notice: 'Objective was successfully deleted!' }
        format.json { render json: @objective.to_json, status: 200 }
      else
        format.html { redirect_to objectives_path, notice: 'Objective was unable to be deleted' }
        format.json { render json: @objective.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def objective_params
    params.require(:objective).permit(:name,:description,:targetgoal,:targetdate)
  end
end
