function LoginController($scope, $window, toastr, UserFactory) {
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
        console.log("Logging In!");
        UserFactory.loginUser($scope.user)
            .success(function(userObj) {
                $window.sessionStorage.token = userObj.auth_token;
                $window.location.href = '/';
                $scope.clearInfo();
            })
            .error(function(errorObj) {
                delete $window.sessionStorage.token;
                toastr.error(errorObj.error, 'Error');
                $scope.clearInfo();
            })
    }

    $scope.signup = function() {
        console.log("Signing Up!");
        UserFactory.registerUser($scope.user)
            .success(function(userObj) {
                $scope.login();
            })
            .error(function(errorObj) {
                toastr.error(errorObj.error, 'Error');
            })
    }

    $scope.logout = function() {
        UserFactory.logoutUser()
            .success(function(obj){
                delete $window.sessionStorage.token;
                $window.location.href = '#/login';
            })
            .error(function(errorObj){
                $scope.message = errorObj.message;
            })
    }
};

angular
    .module('trackto')
    .controller('LoginController', ['$scope', '$window', 'toastr', 'UserFactory', LoginController])