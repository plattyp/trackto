function LoginController($scope, $window, toastr, $auth, UserFactory) {
    $scope.message    = "";
    $scope.auth_token = "";
    $scope.isLogin = true;
    $scope.user = {
        email: "",
        password: ""
    };

    $scope.changeToSignup = function() {
        $scope.isLogin = false;
    }

    $scope.changeToLogin = function() {
        $scope.isLogin = true;
    }

    $scope.clearInfo = function() {
        $scope.user = {
            email: "",
            password: ""
        };
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
    .controller('LoginController', ['$scope', '$window', 'toastr', '$auth', 'UserFactory', LoginController])