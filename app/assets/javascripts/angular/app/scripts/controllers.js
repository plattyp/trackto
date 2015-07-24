function MainCtrl() {
    this.userName = 'Example user';
    this.helloText = 'Welcome in SeedProject';
    this.descriptionText = 'It is an application skeleton for a typical AngularJS web app. You can use it to quickly bootstrap your angular webapp projects and dev environment for these projects.';
    this.logo = 'img/tracktosmaller.png';
};

function LoginController($scope, $window, toaster, UserFactory) {
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
                toaster.pop({
                    type: 'error',
                    title: 'Error',
                    body: errorObj.error,
                    showCloseButton: true
                });
            })
    }

    $scope.logout = function() {
        UserFactory.logoutUser()
            .success(function(obj){
                console.log('Logged Out!');
                $scope.message = obj.message;
                delete $window.sessionStorage.token;
                $window.location.href = '/';
            })
            .error(function(errorObj){
                $scope.message = errorObj.message;
            })
    }
};

function ObjectivesNavigationCtrl($scope) {
    this.objectives = [
      {
        id: '1',
        name: 'Workout more',
        mainMenu: true
      },
      {
        id: '2',
        name: 'Eat healthy',
        mainMenu: true
      },
      {
        id: '3',
        name: 'Learn something',
        mainMenu: false
      },
      {
        id: '4',
        name: 'Take lead',
        mainMenu: false
      },
      {
        id: '5',
        name: 'Another thing',
        mainMenu: false
      }
    ];

    $scope.filterByMainMenu = function(objective) {
        if (objective.mainMenu)
            return objective;

        return false;
    };

    $scope.filterBySecondaryMenu = function(objective) {
        if (objective.mainMenu === false)
            return objective;

        return false;
    };
}

function ObjectiveDetailCtrl($scope, $stateParams) {
    $scope.selected_id = $stateParams.objectiveId;
    $scope.objectives = [
      {
        id: '1',
        name: 'Workout more',
        progress: 80,
        progress_pct: 60,
        pace: 1.5,
        achievability: 'High',
        achievability_pct: 50
      },
      {
        id: '2',
        name: 'Eat healthy',
        progress: 70,
        progress_pct: 50,
        pace: 1.5,
        achievability: 'Low',
        achievability_pct: 50
      },
      {
        id: '3',
        name: 'Learn something',
        progress: 60,
        progress_pct: 40,
        pace: 1.2,
        achievability: 'Medium',
        achievability_pct: 50
      },
      {
        id: '4',
        name: 'Take lead',
        progress: 50,
        progress_pct: 30,
        pace: 1.0,
        achievability: 'Medium',
        achievability_pct: 50
      },
      {
        id: '5',
        name: 'Another thing',
        progress: 40,
        progress_pct: 20,
        pace: 0.8,
        achievability: 'Low',
        achievability_pct: 50
      }
    ];

    $scope.isObjective = function(objective){
        return (objective.id == $scope.selected_id);
    };
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
};

function CreateObjectiveController($scope, toaster, ObjectiveFactory) {
    $scope.objective = {
        name: "",
        targetgoal: "",
        description:""
    };

    var notificationTemplate = 'views/common/notify.html';

    $scope.createObjective = function() {
        ObjectiveFactory.createObjective($scope.objective)
            .success(function() {
                //notify({ message:'Objective was successfully created!', templateUrl: notificationTemplate} );
            })
            .error(function(error) {
                //notify({ message:'Objective could not be created', templateUrl: notificationTemplate} );
            })
    }
};

angular
    .module('trackto')
    .controller('MainCtrl', MainCtrl)
    .controller('LoginController', ['$scope', '$window', 'toaster', 'UserFactory', LoginController])
    .controller('ObjectivesTodayCtrl', ['$scope', 'ObjectiveFactory', ObjectivesTodayCtrl])
    .controller('CreateObjectiveController', ['$scope','toaster','ObjectiveFactory', CreateObjectiveController])
    .controller('ObjectivesNavigationCtrl', ObjectivesNavigationCtrl)
    .controller('ObjectiveDetailCtrl',ObjectiveDetailCtrl)