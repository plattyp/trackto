class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_filter :verify_authenticity_token, if: :json_request?

  acts_as_token_authentication_handler_for User, only: [:destroy], fallback_to_devise: false
  skip_before_filter :verify_signed_out_user, only: :destroy

  skip_before_filter :authenticate_entity_from_token!
  skip_before_filter :authenticate_entity!

  def create
    #warden.authenticate!(:scope => resource_name)
    email = params[:user][:email] if params[:user]
    password = params[:user][:password] if params[:user]
 
    id = User.find_by(email: email).try(:id) if email.presence
    
    if email.nil? or password.nil?
      respond_to do |format|
        format.json {
          render json: {
            error:    'Invalid password or email'
          }, status: HTTP_UNAUTHORIZED
        }
      end
    end

    # Authentication
    @user = User.find_by(email: email)

    #@user = current_user

    puts "Current User Authenticated #{current_user.email}"

    if @user
      if @user.valid_password? params[:user][:password]
        @user.reset_authentication_token!
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
              error:    'Invalid password or email'
            }, status: HTTP_UNAUTHORIZED
          }
        end
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            error:    'Invalid password or email'
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
