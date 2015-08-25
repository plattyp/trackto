function LoginController($scope, $window, toastr, $auth) {
    $scope.message    = "";
    $scope.auth_token = "";
    $scope.isLogin = true;
    $scope.user = {
        email: "",
        password: ""
    };

    $scope.pwdResetForm = {
      email: ""
    };

    $scope.pwdUpdateForm = {
      password: "",
      password_confirmation: ""
    }

    $scope.showForgotPassword = false;

    $scope.changeToSignup = function() {
        $scope.isLogin = false;
    }

    $scope.changeToLogin = function() {
      $scope.showForgotPassword = false;
      $scope.isLogin = true;
    }

    $scope.clearInfo = function() {
        $scope.user = {
            email: "",
            password: ""
        };
    }

    $scope.changeToShowForgotPassword = function(status) {
      $scope.showForgotPassword = status;
    }

    $scope.login = function() {
      $auth.submitLogin($scope.user)
        .then(function(resp) {
          $window.location.href = '/';
          $scope.clearInfo();
        })
        .catch(function(resp) {
          toastr.error(resp.errors[0], 'Error');
          $scope.clearInfo();
        });
    }

    $scope.signup = function() {
        var signupObj = $scope.user;
        signupObj.password_confirmation = signupObj.password;
        $auth.submitRegistration(signupObj)
            .then(function(resp) {
              $scope.clearInfo();
              toastr.info('Please check your email to confirm your account', 'Confirmation Email');
            })
            .catch(function(resp) {
              toastr.error(resp.errors[0], 'Error');
            });
    }

    $scope.resetPassword = function() {
      $auth.requestPasswordReset($scope.pwdResetForm)
        .then(function(resp) {
          toastr.info('Please check your email to reset your password', 'Email Sent');
        })
        .catch(function(resp) {
          // handle error response
        });
    }

    $scope.updatePassword = function() {
      $auth.updateAccount($scope.pwdUpdateForm)
        .then(function(resp) {
          console.log(resp)
          toastr.success('Your password has been updated', 'Success');
        })
        .catch(function(resp) {
          toastr.error('Something wen\'t wrong updating your account', 'Error');
        });
    }

    $scope.logout = function() {
      $auth.signOut()
        .then(function(resp) {
          $window.location.href = '#/login';
        })
        .catch(function(resp) {
          toastr.error(resp.errors[0], 'Error');
        });
    }
};

angular
    .module('trackto')
    .controller('LoginController', ['$scope', '$window', 'toastr', '$auth', LoginController])