class ObjectivesController < ApiController
  #Used temporarily until authentication is put into place
  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :check_access, only: [:show,:destroy,:progress_trend_for_objective,:archive,:unarchive]

  def index
    @objectives = Objective.objectives_with_progress(current_user)

    respond_to do |format|
      format.json { render 'objectives/json/index.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def show
    @obj           = Objective.find_by_id(params[:id])
    @objective     = @obj.get_details(params[:timezoneOffsetSeconds]) if !@obj.nil?
    @subobjectives = @obj.get_subobjectives if !@obj.nil?

    respond_to do |format|
      if !@objective.nil?
        @progress = Progress.progress_history(@obj)
        format.json { render 'objectives/json/show.json.erb', status: 200, content_type: 'application/json' }
      else
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

    #Default value for progress on creation
    @objective.progress = 0

    respond_to do |format|
      if @objective.save
        format.json { render json: @objective.to_json, status: 200 }
      else
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
        format.json { render json: @objective.to_json, status: 200 }
      else
        format.json { render json: @objective.errors, status: :unprocessable_entity }
      end
    end
  end

  def progress_overview
    @progress = Progress.progress_overview_by_user_by_timeframe(current_user.id,'days',14,params[:timezoneOffsetSeconds])
    respond_to do |format|
      format.json { render 'objectives/json/progress_overview.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def progress_trend_for_objective
    limit = 14
    if params[:timeFrame] === 'Weeks'
      limit = 6
    end
    @progress = Progress.progress_overview_by_subobjective_by_timeframe(current_user.id, params[:objective_id], params[:timeFrame],limit, params[:timezoneOffsetSeconds])
    respond_to do |format|
      format.json {render json: @progress.to_json, status: 200, content_type: 'application/json'}
    end
  end

  def objectives_overview
    @details = {
      objectiveCount: Objective.objective_count_by_user(current_user),
      subobjectiveCount: Subobjective.subobjective_count_by_user(current_user),
      progress: Objective.total_progress_per_user(current_user)
    }

    respond_to do |format|
      format.json { render 'objectives/json/objectives_overview.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def subobjectives_today
    @subobjectives = Objective.get_all_subobjectives_not_progressed_today(current_user)
    respond_to do |format|
      format.json { render 'objectives/json/subobjectives_today.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def archive(option = true)
    @objective = Objective.find(params[:objective_id])
    @objective.archived = option

    respond_to do |format|
      if @objective.save
        format.json { render json: @objective.to_json, status: 200, content_type: 'application/json' }
      else
        format.json { render json: @objective.errors, status: :unprocessable_entity }
      end
    end
  end

  def unarchive
    archive(false)
  end

  private

  def check_access
    obj = Objective.find_by_id(params[:objective_id] || params[:id])
    if obj.nil?
      respond_to do |format|
        format.json { render json: {"error": "This objective does not exist"}, status: 404, content_type: 'application/json' }
      end
    else
      if obj.user_id != current_user.id
        respond_to do |format|
          format.json { render json: {"error": "You do not have access to this objective"}, status: 401, content_type: 'application/json' }
        end
      end
    end
  end

  def objective_params
    params.require(:objective).permit(:name,:description, subobjectives_attributes: [:id, :name, :description])
  end
end
