module RegistrationHelpers
  def dummy_registration
    dummy = {
      :user => {
        :email => 'user@test.com',
        :password => 'password',
        :password_confirmation => 'password'
      }
    }
    return dummy
  end
end