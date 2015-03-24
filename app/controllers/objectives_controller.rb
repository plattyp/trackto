class ObjectivesController < ApplicationController

	def index
		@objectives = Objective.all_objectives
	end
end
