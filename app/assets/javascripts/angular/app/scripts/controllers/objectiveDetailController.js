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
    $scope.activeTimeFrame = 'Weeks';
    $scope.progressTrendLabels = [];
    $scope.progressTrendSeries = [];
    $scope.progressTrendData   = [];

    // Create Subobjective Modal
    $scope.createSubobjective = {
        name: "",
        description: ""
    };

    $scope.submitCreateSubobjective = function() {
        console.log('Called!');
    }

    getObjective($scope.selected_id);
    getObjectiveProgressTrend($scope.selected_id);

    $scope.isArchived = function() {
        return $scope.objective.archived || false;
    }

    $scope.hideNoDataMessage = function() {
        return $scope.objective.sub_progress > 0;
    }

    $scope.longestStreakMessage = function() {
        if ($scope.objective.hasOwnProperty("longest_streak")) {
            return $scope.objective.longest_streak.begin_date + " - " + $scope.objective.longest_streak.end_date;
        }
        return "";
    }

    $scope.currentStreakMessage = function() {
        if ($scope.objective.hasOwnProperty("current_streak")) {
            return $scope.objective.current_streak.begin_date + " - Today";
        }
        return "";
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

    $scope.changeProgressTimeFrame = function(timeframe) {
        $scope.activeTimeFrame = timeframe;
        getObjectiveProgressTrend($scope.selected_id);
    }

    function getObjectiveProgressTrend(objectiveId) {
        ObjectiveFactory.getProgressTrendForObjective(objectiveId, $scope.activeTimeFrame)
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

    $scope.addSubobjective = function() {
        console.log('Add Subobjective!');
    }
};

angular
    .module('trackto')
    .controller('ObjectiveDetailCtrl',['$scope', '$stateParams', '$window', 'toastr', 'ObjectiveFactory', ObjectiveDetailCtrl])