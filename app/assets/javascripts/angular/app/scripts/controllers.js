function MainCtrl($scope) {
    this.logo = 'img/tracktosmaller.png';

    $scope.$on('tidyUp', function(event) {
        $scope.$broadcast('resetNav');
    });

    $scope.$on('progressMade', function(event) {
        $scope.$broadcast('resetProgressOverview');
    });
};

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
    $scope.subobjectives = [];
    $scope.progressTrend = {};
    $scope.selected_id = $stateParams.objectiveId;

    // Breakdown Chart
    $scope.breakdownLabels = [];
    $scope.breakdownSeries = ['Progress Breakdown'];
    $scope.breakdownData = [];

    // Progress Trend Chart
    $scope.progressTrendLabels = [];
    $scope.progressTrendSeries = [];
    $scope.progressTrendData   = [];

    getObjective($scope.selected_id);
    getObjectiveProgressTrend($scope.selected_id);

    $scope.isArchived = function() {
        return $scope.objective.archived || false;
    }

    $scope.showNoDataMessage = function() {
        return $scope.breakdownData.length > 0;
    }

    function getObjective(objectiveId) {
        ObjectiveFactory.getObjective(objectiveId)
            .success(function (obj) {
                $scope.objective = obj['objective'];
                $scope.subobjectives = obj['subobjectives'];
                if (Object.keys($scope.subobjectives).length > 0) {
                    reloadBreakdownChartData();
                }
            })
            .error(function (error) {
                if (error) {
                    $scope.status = 'Unable to load objectives data: ' + error.message;
                }
            });
    }

    function reloadBreakdownChartData() {
        var subs = $scope.subobjectives;
        $scope.labels = [];
        $scope.data = [];
        var data = [];
        for (var i in subs) {
            $scope.breakdownLabels.push(subs[i].name);
            $scope.breakdownData.push(subs[i].progress);
        }
    }

    function getObjectiveProgressTrend(objectiveId) {
        ObjectiveFactory.getProgressTrendForObjective(objectiveId)
            .success(function (obj){
                $scope.progressTrend = obj;
                if(Object.keys(obj).length > 0) {
                    reloadProgressTrendChartData();
                }
            })
            .error(function (error) {
                if (error) {
                    $scope.status = 'Unable to load progress trend data: ' + error.message;
                }
            })
    }

    function reloadProgressTrendChartData() {
        var prg = $scope.progressTrend;
        $scope.progressTrendSeries = [];
        $scope.progressTrendLabels = [];
        $scope.progressTrendData = [];
        for (var sub in prg) {
            $scope.progressTrendSeries.push(sub);
            var dataPoints   = prg[sub];
            var newDataArray = [];
            for (var i in dataPoints){
                // If label doesn't exist, add it
                if ($scope.progressTrendLabels.indexOf(i) < 0) {
                    $scope.progressTrendLabels.push(i);
                }
                // Add data regardless to the multidimensional array
                newDataArray.push(dataPoints[i]);
            }
            $scope.progressTrendData.push(newDataArray);
        }
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
                $scope.objective = obj;
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
                $scope.objective = obj;
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

function ObjectivesTodayCtrl($scope, toastr, ObjectiveFactory) {
    $scope.objectives = [];

    getSubobjectivesToday();

    function getSubobjectivesToday() {
        ObjectiveFactory.getSubobjectivesToday()
            .success(function (objs) {
                $scope.objectives = objs['subobjectives'];
            })
            .error(function (error) {
                $scope.status = 'Unable to load subobjectives data: ' + error.message;
            });
    }

    $scope.addProgressSubmit = function(index, subobjectiveId) {
        ObjectiveFactory.addProgressSubobjective(subobjectiveId)
            .success(function (subobjective) {
                $scope.objectives.splice(index,1);
                $scope.$emit('progressMade');
            })
            .error(function (error) {
                toastr.error("Unable to add progress to the subojective", 'error');
            });
    }

    $scope.ignoreSubobjectiveSubmit = function(index, subobjectiveId) {
        $scope.objectives.splice(index,1);
    }
};

function CreateObjectiveController($scope, $window, toastr, StepsService, ObjectiveFactory) {
    $scope.objective = {
        name: "",
        description:"",
        subobjectives_attributes: [{
                name: "",
                description: ""
        }]
    };

    // Functions for moving the form / validation
    $scope.validateObjectivePortion = function() {
        if (!$scope.objective.name || $scope.objective.name.length === 0) {
            toastr.error("Objective name is required", 'Error');
            StepsService.steps().cancel();
        }
    };

    $scope.validateSubbjectivePortion = function() {
        var valid = true;
        var error = "";
        if ($scope.objective.subobjectives_attributes.length > 0) {
            var subs = $scope.objective.subobjectives_attributes;
            for (var i in subs) {
                if (subs[i].name === "") {
                    error = "A subobjective must have a name";
                    valid = false;
                }
            }
        } else {
            error = "Atleast one subobjective is required";
            valid = false;
        }

        if (valid) {
            $scope.createObjective();
        } else {
            toastr.error(error,'Error');
        }
    };

    // Functions for the adding / removing subobjectives to the form
    $scope.showRemoveSubobjectiveButton = function() {
        return $scope.objective.subobjectives_attributes.length > 1;
    };

    $scope.showAddSubobjectiveButton = function() {
        var subs = $scope.objective.subobjectives_attributes;
        var shouldShow = true;
        for (var i in subs) {
            if (subs[i].name === "" && subs[i].description === "") {
                shouldShow = false;
            }
        }
        return shouldShow;
    };

    $scope.removeSub = function(index) {
        $scope.objective.subobjectives_attributes.splice(index,1);
    };

    $scope.addAnotherSub = function() {
        var newSub = {
            name: "",
            description: "",
            active: true
        };
        $scope.objective.subobjectives_attributes.push(newSub);
    };

    //

    function clearObjectiveFields() {
        $scope.objective = {
            name: "",
            description:"",
            subobjectives_attributes: [{
                    name: "",
                    description: ""
            }]
        };
    }

    function cleanObjective() {
        var objective = $scope.objective;
        var subs = objective.subobjectives_attributes;
        for (var i in subs) {
            if (subs[i].name === "" && subs[i].description === "") {
                subs.splice(i,1);
            }
        }
        objective.subobjectives_attributes = subs;
        return objective;
    }

    $scope.createObjective = function() {
        var objective = cleanObjective();
        ObjectiveFactory.createObjective(objective)
            .success(function(obj) {
                $window.location.href = '/#/index/objectives/' + obj['id'];
                toastr.success("You successfully created an objective", 'Success');
                $scope.$emit('tidyUp');
                clearObjectiveFields();
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

    $scope.activeTimeFrame = 'Days';

    $scope.changeProgressTimeFrame = function(timeframe) {
        $scope.activeTimeFrame = timeframe;
        getProgressOverview();
    }

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
    $scope.data = [];

    $scope.showNoDataMessage = function() {
        return $scope.data.length > 0 ? true : false;
    }

    $scope.$on('resetProgressOverview', function(event) {
        getProgressOverview();
    });

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
    .controller('ObjectivesTodayCtrl', ['$scope', 'toastr','ObjectiveFactory', ObjectivesTodayCtrl])
    .controller('CreateObjectiveController', ['$scope','$window','toastr','StepsService','ObjectiveFactory', CreateObjectiveController])
    .controller('ObjectiveDetailCtrl',['$scope', '$stateParams', '$window', 'toastr', 'ObjectiveFactory', ObjectiveDetailCtrl])
    .controller('ObjectiveDashboard',['$scope','DashboardFactory', ObjectiveDashboard])