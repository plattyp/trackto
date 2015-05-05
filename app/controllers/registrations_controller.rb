class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_filter :verify_authenticity_token, if: :json_request?

  acts_as_token_authentication_handler_for User
  skip_before_filter :authenticate_entity_from_token!, only: [:create]
  skip_before_filter :authenticate_entity!, only: [:create]

  skip_before_filter :authenticate_scope!
  append_before_filter :authenticate_scope!, only: [:destroy]

  def create
    build_resource(sign_up_params)

    if User.find_by(email: resource.email)
      status = HTTP_UNAUTHORIZED
      error = "The email address used already exists"
    else
      if resource.save
        status = HTTP_OK
        message = "Successfully created new account for email #{sign_up_params[:email]}."
      else
        clean_up_passwords resource
        status = HTTP_UNAUTHORIZED
        error = "Failed to create new account for email #{sign_up_params[:email]}."
      end
    end

    if message
      respond_to do |format|
        format.json {
          render json: {
            message: message
          }, status: status
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            error: error
          }, status: status
        }
      end
    end
  end

  def destroy
    if resource.destroy
      status = HTTP_OK
      message = "Successfully deleted the account for email #{sign_up_params[:email]}."

      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    else
      status = HTTP_INTERNAL_SERVER_ERROR
      message = "Failed to delete the account for email #{sign_up_params[:email]}."
    end

    respond_to do |format|
      format.json {
        render json: {
          message: message
        }, status: status
      }
    end
  end

  private

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

  def json_request?
    request.format.json?
  end
end
