class SubobjectivesController < ApplicationController
  #Used temporarily until authentication is put into place
  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :find_objective, except: :add_progress

  def index
    @subobjectives = Subobjective.all_subobjectives(@objective)
  end

  def create
    @subobjective = @objective.subobjectives.build(subobjective_params)

    respond_to do |format|
      if @subobjective.save
        format.json { render json: @subobjective.to_json, status: 200 }
      else
        format.json { render json: @subobjective.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def add_progress
    @subobjective = Subobjective.find(params[:subobjective_id])
    @progress = @subobjective.progresses.new(amount: 1)

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

  def subobjective_params
    params.require(:subobjective).permit(:name,:description)
  end

  def find_objective
    @objective = Objective.find(params[:objective_id])
  end
end
