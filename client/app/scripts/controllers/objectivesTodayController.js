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

angular
    .module('trackto')
    .controller('ObjectivesTodayCtrl', ['$scope', 'toastr','ObjectiveFactory', ObjectivesTodayCtrl])