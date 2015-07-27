function MainCtrl($scope) {
    this.userName = 'Example user';
    this.helloText = 'Welcome in SeedProject';
    this.descriptionText = 'It is an application skeleton for a typical AngularJS web app. You can use it to quickly bootstrap your angular webapp projects and dev environment for these projects.';
    this.logo = 'img/tracktosmaller.png';

    $scope.$on('tidyUp', function(event) {
        $scope.$broadcast('resetNav');
    });
};

function LoginController($scope, $window, toastr, UserFactory) {
    $scope.message    = "";
    $scope.auth_token = "";
    $scope.user = {
        email: "",
        password: ""
    };

    $scope.login = function() {
        UserFactory.loginUser($scope.user)
            .success(function(userObj) {
                $window.sessionStorage.token = userObj.auth_token;
                $window.location.href = '/';
            })
            .error(function(errorObj) {
                delete $window.sessionStorage.token;
                toastr.error(errorObj.error, 'Error');
            })
    }

    $scope.logout = function() {
        UserFactory.logoutUser()
            .success(function(obj){
                $scope.message = obj.message;
                delete $window.sessionStorage.token;
                $window.location.href = '/';
            })
            .error(function(errorObj){
                $scope.message = errorObj.message;
            })
    }
};

function ObjectivesNavigationCtrl($scope, ObjectiveFactory) {
    $scope.objectives = [];

    getObjectives();

    function getObjectives() {
        ObjectiveFactory.getObjectives()
            .success(function (objs) {
                $scope.objectives = objs['objectives'];
            })
            .error(function (error) {
                $scope.status = 'Unable to load objectives data: ' + error.message;
            });
    };

    $scope.filterByMainMenu = function(objective) {
        return objective;
    };

    $scope.filterBySecondaryMenu = function(objective) {
        if ($scope.objectives.mainMenu === true)
            return objective;

        return false;
    };

    $scope.showArchivedMenu = function() {
        return false;
    };

    $scope.$on('resetNav', function(event) {
        getObjectives();
    });
};

function ObjectiveDetailCtrl($scope, $stateParams, $window, toastr, ObjectiveFactory) {
    $scope.selected_id = $stateParams.objectiveId;

    getObjective($scope.selected_id);

    function getObjective(objectiveId) {
        ObjectiveFactory.getObjective(objectiveId)
            .success(function (obj) {
                $scope.objective = obj['objective'];
            })
            .error(function (error) {
                if (error) {
                    $scope.status = 'Unable to load objectives data: ' + error.message;
                }
            });
    }

    $scope.deleteObjective = function() {
        var objectiveId = $scope.selected_id
        ObjectiveFactory.deleteObjective(objectiveId)
            .success(function (obj) {
                $scope.$emit('tidyUp');
                $window.location.href = '#/index/dashboard';
                toastr.info("You have successfully deleted the objective: " + obj.name, 'Success');
            })
            .error(function (error) {
                if (error) {
                    toastr.error("Unable to load objective", 'error');
                }
            });
    }
};

function ObjectivesTodayCtrl($scope, ObjectiveFactory) {
    $scope.objectives = [];

    getObjectives();

    function getObjectives() {
        ObjectiveFactory.getObjectives()
            .success(function (objs) {
                $scope.objectives = objs['objectives'];
            })
            .error(function (error) {
                $scope.status = 'Unable to load objectives data: ' + error.message;
            });
    }

    $scope.addProgressSubmit = function(index, objectiveId) {
        $scope.objectives.splice(index,1);
        //console.log('Adding Progress for Objective: ' + objectiveId);
    }

    $scope.ignoreSubobjectiveSubmit = function(index, objectiveId) {
        $scope.objectives.splice(index,1);
        //console.log('Ignoring Subobjective Progress for Objective: ' + objectiveId);
    }
};

function CreateObjectiveController($scope, toastr, ObjectiveFactory) {
    $scope.objective = {
        name: "",
        targetgoal: "",
        description:""
    };

    $scope.createObjective = function() {
        ObjectiveFactory.createObjective($scope.objective)
            .success(function() {
                toastr.success("You successfully created an objective", 'Success');
                $scope.$emit('tidyUp');
            })
            .error(function(error) {
                toastr.error("The objective could not be created", 'Error');
            })
    };
};

function ObjectiveProgressChart($scope) {
  $scope.labels = ["January", "February", "March", "April", "May", "June", "July"];
  $scope.series = ['Objective Progress'];
  $scope.data = [
    [65, 59, 80, 81, 56, 55, 40]
  ];
};

angular
    .module('trackto')
    .controller('MainCtrl', ['$scope', MainCtrl])
    .controller('ObjectivesNavigationCtrl', ['$scope', 'ObjectiveFactory', ObjectivesNavigationCtrl])
    .controller('LoginController', ['$scope', '$window', 'toastr', 'UserFactory', LoginController])
    .controller('ObjectivesTodayCtrl', ['$scope', 'ObjectiveFactory', ObjectivesTodayCtrl])
    .controller('CreateObjectiveController', ['$scope','toastr','ObjectiveFactory', CreateObjectiveController])
    .controller('ObjectiveDetailCtrl',['$scope', '$stateParams', '$window', 'toastr', 'ObjectiveFactory', ObjectiveDetailCtrl])
    .controller('ObjectiveProgressChart',['$scope', ObjectiveProgressChart])