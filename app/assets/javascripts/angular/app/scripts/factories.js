function ObjectiveFactory($http) {
    var urlBase = '/api/objectives';
    var objectiveFactory = {};

    objectiveFactory.getObjectives = function () {
        return $http.get(urlBase);
    };

    objectiveFactory.getObjective = function(objectiveId) {
        return $http.get(urlBase + '/' + objectiveId);
    };

    objectiveFactory.createObjective = function (objective) {
        return $http.post(urlBase, {"objective": objective});
    };

    objectiveFactory.deleteObjective = function (objectiveId) {
        return $http.delete(urlBase + '/' + objectiveId);
    };

    objectiveFactory.archiveObjective = function(objectiveId) {
        return $http.post(urlBase + '/' + objectiveId + '/archive');
    };

    objectiveFactory.unarchiveObjective = function(objectiveId) {
        return $http.post(urlBase + '/' + objectiveId + '/unarchive');
    };

    return objectiveFactory;
};

function DashboardFactory($http) {
    var urlBase = '/api/';
    dashboardFactory = {};

    dashboardFactory.getProgressOverview = function() {
        return $http.get(urlBase + 'progress_overview');
    }

    dashboardFactory.getObjectivesOverview = function() {
        return $http.get(urlBase + 'objectives_overview');
    }

    return dashboardFactory;
}

function UserFactory($http) {
    var urlBase = '/api/';
    var userFactory = {};

    userFactory.loginUser = function(userObj) {
        var params = 'user[email]=' + userObj.email + '&user[password]=' + userObj.password;
        return $http.post(urlBase + 'login?' + params);   
    };

    userFactory.logoutUser = function(userObj) {
        return $http.delete(urlBase + 'logout');
    };

    return userFactory;
};

angular
    .module('trackto')
    .factory('ObjectiveFactory', ['$http', ObjectiveFactory])
    .factory('UserFactory', ['$http', UserFactory])
    .factory('DashboardFactory', ['$http', DashboardFactory])