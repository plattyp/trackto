function ObjectiveFactory($http) {
    var urlBase = '/api/objectives';
    var timeZoneOffset = new Date().getTimezoneOffset() * -60;
    var objectiveFactory = {};

    // Methods for Objectives
    objectiveFactory.getObjectives = function () {
        return $http.get(urlBase);
    };

    objectiveFactory.getObjective = function(objectiveId) {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset;
        return $http.get(urlBase + '/' + objectiveId + '?' + params);
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

    // Methods to support charts
    objectiveFactory.getSubobjectivesToday = function() {
        return $http.get('/api/subobjectives_today');
    };

    objectiveFactory.getProgressTrendForObjective = function(objectiveId,timeFrame) {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset + '&timeFrame=' + timeFrame;
        return $http.get(urlBase + '/' + objectiveId + '/progress_trend?' + params);
    };

    // Methods for Subobjectives
    objectiveFactory.createSubobjective = function(objectiveId, subobjective) {
        return $http.post('/api/subobjectives/', {"objective_id": objectiveId, "subobjective": subobjective});
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

    dashboardFactory.getProgressOverview = function(timeFrame) {
        var params = 'timezoneOffsetSeconds=' + timeZoneOffset + '&timeFrame=' + timeFrame;
        return $http.get(urlBase + 'progress_overview?' + params);
    }

    dashboardFactory.getObjectivesOverview = function() {
        return $http.get(urlBase + 'objectives_overview');
    }

    return dashboardFactory;
}

angular
    .module('trackto')
    .factory('ObjectiveFactory', ['$http', ObjectiveFactory])
    .factory('DashboardFactory', ['$http', DashboardFactory])