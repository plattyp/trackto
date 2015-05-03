class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_filter :verify_authenticity_token, if: :json_request?

  acts_as_token_authentication_handler_for User, only: [:destroy], fallback_to_devise: false
  skip_before_filter :verify_signed_out_user, only: :destroy

  skip_before_filter :authenticate_entity_from_token!
  skip_before_filter :authenticate_entity!

  def create
    warden.authenticate!(:scope => resource_name)
    @user = current_user
    
    if @user
      if @user.valid_password? params[:user][:password]
        respond_to do |format|
          format.json {
            render json: {
              message:    'Logged in',
              auth_token: @user.authentication_token
            }, status: HTTP_OK
          }
        end
      else
        respond_to do |format|
          format.json {
            render json: {
              message:    'Invalid password or email'
            }, status: HTTP_UNAUTHORIZED
          }
        end
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            message:    'Invalid password or email'
          }, status: HTTP_UNAUTHORIZED
        }
      end
    end
  end

  def destroy
    if user_signed_in?
      @user = current_user
      @user.authentication_token = nil
      @user.save

      respond_to do |format|
        format.json {
          render json: {
            message: 'Logged out successfully.'
          }, status: HTTP_OK
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            message: 'Failed to log out. User must be logged in.'
          }, status: HTTP_UNAUTHORIZED
        }
      end
    end
  end

  private

  def json_request?
    request.format.json?
  end
end
