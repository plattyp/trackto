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
        if (objective.archived === false)
            return objective;

        return false;
    };

    $scope.filterBySecondaryMenu = function(objective) {
        if (objective.archived === true)
            return objective;

        return false;
    };

    $scope.showArchivedMenu = function() {
        var objs = $scope.objectives;

        for (var i in objs) {
            if (objs[i].archived === true)
                return true;
        }

        return false;
    };

    $scope.$on('resetNav', function(event) {
        getObjectives();
    });
};

function ObjectiveDetailCtrl($scope, $stateParams, $window, toastr, ObjectiveFactory) {
    $scope.objective = {};
    $scope.selected_id = $stateParams.objectiveId;

    getObjective($scope.selected_id);

    $scope.isArchived = function() {
        return $scope.objective.archived;
    }

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

    $scope.archiveObjective = function() {
        var objectiveId = $scope.selected_id
        ObjectiveFactory.archiveObjective(objectiveId)
            .success(function (obj) {
                $scope.$emit('tidyUp');
                toastr.info("You have successfully archived the objective: " + obj.name, 'Success');
            })
            .error(function (error) {
                if (error) {
                    toastr.error("Unable to archive the objective", 'error');
                }
            });
    }

    $scope.unarchiveObjective = function() {
        var objectiveId = $scope.selected_id
        ObjectiveFactory.unarchiveObjective(objectiveId)
            .success(function (obj) {
                $scope.$emit('tidyUp');
                toastr.info("You have successfully unarchived the objective: " + obj.name, 'Success');
            })
            .error(function (error) {
                if (error) {
                    toastr.error("Unable to archive the objective", 'error');
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

function ObjectiveDashboard($scope, DashboardFactory) {
    getObjectivesOverview();
    getProgressOverview();
    // To support dashboard metrics
    $scope.objectivesCount = 0;
    $scope.subobjectivesCount = 0;
    $scope.progressCount = 0;

    function getObjectivesOverview() {
        DashboardFactory.getObjectivesOverview()
            .success(function (data) {
                $scope.objectivesCount = data['objectivesCount'];
                $scope.subobjectivesCount = data['subobjectivesCount'];
                $scope.progressCount = data['progressCount'];
            })
            .error(function (error) {
                $scope.status = 'Unable to load objectives data: ' + error.message;
            });
    }

    // To support the progress trend chart
    $scope.progress = {};
    $scope.labels = [];
    $scope.series = ['Objective Progress'];
    $scope.data = [
        [65, 59, 80, 81, 56, 55, 40]
    ];

    function getProgressOverview() {
        DashboardFactory.getProgressOverview()
            .success(function (prg) {
                $scope.progress = prg['progress'];
                reloadChartData();
            })
            .error(function (error) {
                $scope.status = 'Unable to load objectives data: ' + error.message;
            });
    }

    function reloadChartData() {
        var progress = $scope.progress;
        $scope.labels = [];
        $scope.data = [];
        var data = [];
        for (var key in progress) {
            $scope.labels.push(capitalizeFirstLetter(key));
            data.push(progress[key]);
        }
        $scope.data.push(data);
    }

    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
};

angular
    .module('trackto')
    .controller('MainCtrl', ['$scope', MainCtrl])
    .controller('ObjectivesNavigationCtrl', ['$scope', 'ObjectiveFactory', ObjectivesNavigationCtrl])
    .controller('LoginController', ['$scope', '$window', 'toastr', 'UserFactory', LoginController])
    .controller('ObjectivesTodayCtrl', ['$scope', 'ObjectiveFactory', ObjectivesTodayCtrl])
    .controller('CreateObjectiveController', ['$scope','toastr','ObjectiveFactory', CreateObjectiveController])
    .controller('ObjectiveDetailCtrl',['$scope', '$stateParams', '$window', 'toastr', 'ObjectiveFactory', ObjectiveDetailCtrl])
    .controller('ObjectiveDashboard',['$scope','DashboardFactory', ObjectiveDashboard])