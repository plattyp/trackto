class SubobjectivesController < ApplicationController
  #Used temporarily until authentication is put into place
  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :find_objective

  def index
    @subobjectives = Subobjective.all_subobjectives(@objective)
  end

  def show
  end

  def new
    @subobjective = @objective.subobjectives.build
  end

  def create
    @subobjective = @objective.subobjectives.build(subobjective_params)

    respond_to do |format|
      if @subobjective.save
        format.html { redirect_to objective_path(@objective), notice: 'Subobjective was successfully created!' }
        format.json { render json: @subobjective.to_json, status: 200 }
      else
        format.html { render :new }
        format.json { render json: @subobjective.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def destroy
  end

  private

  def subobjective_params
    params.require(:subobjective).permit(:name,:description)
  end

  def find_objective
    @objective = Objective.find(params[:objective_id])
  end
end
