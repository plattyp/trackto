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

angular
    .module('trackto')
    .controller('ObjectivesNavigationCtrl', ['$scope', 'ObjectiveFactory', ObjectivesNavigationCtrl])