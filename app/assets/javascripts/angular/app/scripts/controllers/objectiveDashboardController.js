function ObjectiveDashboard($scope, DashboardFactory) {
    // To support dashboard metrics
    $scope.objectivesCount = 0;
    $scope.subobjectivesCount = 0;
    $scope.progressCount = 0;

    $scope.activeTimeFrame = 'Days';

    getObjectivesOverview();
    getProgressOverview();

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
        DashboardFactory.getProgressOverview($scope.activeTimeFrame)
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
    .controller('ObjectiveDashboard',['$scope','DashboardFactory', ObjectiveDashboard])