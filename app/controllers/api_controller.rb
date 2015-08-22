class ApiController < ApplicationController
  before_action :authenticate_user!
  respond_to :json, :html

  private

  def json_request?
    request.format.json?
  end
end
