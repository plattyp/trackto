function MainCtrl($scope) {
    this.logo = 'img/tracktosmaller.png';

    $scope.$on('tidyUp', function(event) {
        $scope.$broadcast('resetNav');
    });

    $scope.$on('progressMade', function(event) {
        $scope.$broadcast('resetProgressOverview');
    });
};

angular
    .module('trackto')
    .controller('MainCtrl', ['$scope', MainCtrl])