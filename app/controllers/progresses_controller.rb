class ProgressesController < ApiController
  before_filter :find_context, except: :all_progress

  def all_progress
    @progresses = Progress.all_progress

    respond_to do |format|
      format.json { render 'progresses/json/all_progress.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def index
    @progresses = Progress.progress_history(@objective)

    respond_to do |format|
      format.json { render 'progresses/json/index.json.erb', status: 200, content_type: 'application/json' }
    end
  end

  def create
    @context = find_context
    @progress = @context.progresses.new(progress_params)
    
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

  def progress_params
    params.require(:progress).permit!
  end

  def find_context
    if params[:objective_id]
      id = params[:objective_id]
      Objective.find(params[:objective_id])
    else
      id = params[:subobjective_id]
      Subobjective.find(params[:subobjective_id])
    end
  end

  def context_path
    if params[:objective_id]
      objective_path(params[:objective_id])
    else
      objective_path(Subobjective.find(params[:subobjective_id]).objective_id)
    end
  end

end
