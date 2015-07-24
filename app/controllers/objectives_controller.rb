class ObjectivesController < ApiController
  #Used temporarily until authentication is put into place
  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }

  def index
    @objectives = Objective.objectives_with_progress(current_user)

    respond_to do |format|
      format.html
      format.json { render 'objectives/json/index.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def show
    @objective = Objective.find_by_id(params[:id])
    @subobjectives = @objective.get_subobjectives

    respond_to do |format|
      if !@objective.nil?
        @progress = Progress.progress_history(@objective)

        format.html
        format.json { render 'objectives/json/show.json.erb', status: 200, content_type: 'application/json' }
      else
        format.html { redirect_to objectives_path, alert: 'Objective does not exist' }
        format.json { render json: {"error": "Objective does not exist"}, status: 404, content_type: 'application/json' }
      end
    end
  end

  def new
    @objective = Objective.new
  end

  def create
    @objective = Objective.new(objective_params)

    #Associate the user with the objective
    @objective.user_id = current_user.id

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

    #A user should only be able delete their own objectives
    if @objective.user_id == current_user.id
      @objective.destroy
    end

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
