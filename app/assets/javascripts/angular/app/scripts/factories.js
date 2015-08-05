function ObjectiveFactory($http) {
    var urlBase = '/api/objectives';
    var timeZoneOffset = new Date().getTimezoneOffset() * -60;
    var objectiveFactory = {};

    objectiveFactory.getObjectives = function () {
        return $http.get(urlBase);
    };

    objectiveFactory.getObjective = function(objectiveId) {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset;
        return $http.get(urlBase + '/' + objectiveId + '?' + params);
    };

    objectiveFactory.getProgressTrendForObjective = function(objectiveId,timeFrame) {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset + '&timeFrame=' + timeFrame;
        return $http.get(urlBase + '/' + objectiveId + '/progress_trend?' + params);
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

    objectiveFactory.getSubobjectivesToday = function() {
        return $http.get('/api/subobjectives_today');
    };

    objectiveFactory.addProgressSubobjective = function(subobjectiveId) {
        return $http.post('/api/subobjectives/' + subobjectiveId + '/add_progress');
    };

    return objectiveFactory;
};

function DashboardFactory($http) {
    var urlBase = '/api/';
    var timeZoneOffset = new Date().getTimezoneOffset() * -60;
    dashboardFactory = {};

    dashboardFactory.getProgressOverview = function() {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset;
        return $http.get(urlBase + 'progress_overview?' + params);
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

    userFactory.registerUser = function(userObj) {
        var params = 'user[email]=' + userObj.email + '&user[password]=' + userObj.password;
        return $http.post(urlBase + 'register?' + params);   
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