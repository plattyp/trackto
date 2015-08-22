class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  respond_to :json, :html

  # protect_from_forgery with: :exception
  # before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:sign_in) do |u|
  #     u.permit(:email, :password)
  #   end
  #   devise_parameter_sanitizer.for(:sign_up) do |u|
  #     u.permit(:email, :password, :password_confirmation)
  #   end
  # end

  # def set_user
  #   @user = current_user
  # end
end
