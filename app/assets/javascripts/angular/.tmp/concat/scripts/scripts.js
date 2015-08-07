$(document).ready(function () {
    // Full height
    function fix_height() {
        var heightWithoutNavbar = $("body > #wrapper").height() - 61;
        $(".sidebard-panel").css("min-height", heightWithoutNavbar + "px");

        var navbarHeigh = $('nav.navbar-default').height();
        var wrapperHeigh = $('#page-wrapper').height();

        if(navbarHeigh > wrapperHeigh){
            $('#page-wrapper').css("min-height", navbarHeigh + "px");
        }

        if(navbarHeigh < wrapperHeigh){
            $('#page-wrapper').css("min-height", $(window).height()  + "px");
        }
    }

    $(window).bind("load resize scroll", function() {
        if(!$("body").hasClass('body-small')) {
            fix_height();
        }
    })

    setTimeout(function(){
        fix_height();
    })
});

// Minimalize menu when screen is less than 768px
$(function() {
    $(window).bind("load resize", function() {
        if ($(this).width() < 769) {
            $('body').addClass('body-small')
        } else {
            $('body').removeClass('body-small')
        }
    })
});

(function () {
    angular.module('trackto', [
        'ui.router',
        'ui.bootstrap',
        'toastr',
        'chart.js',
        'angular-steps'
        //'oc.lazyLoad',                  // ocLazyLoad
        //'ngIdle'                        // Idle timer
    ])
})();
/* Router */
function config($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/index/dashboard");

    var authenticated = ['$window','$q', function($window,$q) {
        var deferred = $q.defer();
        if ($window.sessionStorage.token) {
            deferred.resolve();
        } else {
            deferred.reject('Not logged in');
        }
        return deferred.promise;
    }]

    $stateProvider
        .state('index', {
            abstract: true,
            url: "/index",
            templateUrl: "views/common/content.html",
            resolve: {
                authenticated: authenticated
            }
        })
        .state('index.main', {
            url: "/main",
            templateUrl: "views/main.html",
            data: { pageTitle: 'Example view' },
            resolve: {
                authenticated: authenticated
            }
        })
        .state('index.minor', {
            url: "/minor",
            templateUrl: "views/minor.html",
            data: { pageTitle: 'Example view' },
            resolve: {
                authenticated: authenticated
            }
        })
        .state('index.dashboard', {
            url: "/dashboard",
            templateUrl: "views/dashboard.html",
            data: { pageTitle: 'Dashboard' },
            resolve: {
                authenticated: authenticated
            }
        })
        .state('index.objective', {
            url: "/objectives/:objectiveId",
            templateUrl: "views/objective_dashboard.html",
            data: {pageTitle: 'Objective' },
            resolve: {
                authenticated: authenticated
            }
        })
        .state('index.new_objective', {
            url: "/objective/new",
            templateUrl: "views/new_objective.html",
            data: {pageTitle: 'Create Objective' },
            resolve: {
                authenticated: authenticated
            }
        })
        .state('login', {
            url: "/login",
            templateUrl: "views/login.html",
        })
}
angular
    .module('trackto')
    .config(config)
    .run(function ($rootScope, $state, $log) {
      $rootScope.$on('$stateChangeError', function () {
        // Redirect user to our login page
        $state.go('login');
      });
    });
function pageTitle($rootScope, $timeout) {
    return {
        link: function(scope, element) {
            var listener = function(event, toState, toParams, fromState, fromParams) {
                // Default title - load on Dashboard 1
                var title = 'Trackto | Track your goals';
                // Create your own title pattern
                if (toState.data && toState.data.pageTitle) title = 'Trackto | ' + toState.data.pageTitle;
                $timeout(function() {
                    element.text(title);
                });
            };
            $rootScope.$on('$stateChangeStart', listener);
        }
    }
};

/**
 * sideNavigation - Directive for run metsiMenu on sidebar navigation
 */
function sideNavigation($timeout) {
    return {
        restrict: 'A',
        link: function(scope, element) {
            // Call the metsiMenu plugin and plug it to sidebar navigation
            $timeout(function(){
                element.metisMenu();
            });
        }
    };
};

/**
 * iboxTools - Directive for iBox tools elements in right corner of ibox
 */
function iboxTools($timeout) {
    return {
        restrict: 'A',
        scope: true,
        templateUrl: 'views/common/ibox_tools.html',
        controller: function ($scope, $element) {
            // Function for collapse ibox
            $scope.showhide = function () {
                var ibox = $element.closest('div.ibox');
                var icon = $element.find('i:first');
                var content = ibox.find('div.ibox-content');
                content.slideToggle(200);
                // Toggle icon from up to down
                icon.toggleClass('fa-chevron-up').toggleClass('fa-chevron-down');
                ibox.toggleClass('').toggleClass('border-bottom');
                $timeout(function () {
                    ibox.resize();
                    ibox.find('[id^=map-]').resize();
                }, 50);
            },
                // Function for close ibox
                $scope.closebox = function () {
                    var ibox = $element.closest('div.ibox');
                    ibox.remove();
                }
        }
    };
};

function objectiveHeader($timeout) {
    return {
        restrict: 'A',
        scope: true,
        templateUrl: 'views/common/objective_header.html',
        controller: function ($scope, $element) {
            // Function for collapse ibox
            $scope.showhide = function () {
                var ibox = $element.closest('div.ibox');
                var icon = $element.find('i:first');
                var content = ibox.find('div.ibox-content');
                content.slideToggle(200);
                // Toggle icon from up to down
                icon.toggleClass('fa-chevron-up').toggleClass('fa-chevron-down');
                ibox.toggleClass('').toggleClass('border-bottom');
                $timeout(function () {
                    ibox.resize();
                    ibox.find('[id^=map-]').resize();
                }, 50);
            },
                // Function for close ibox
                $scope.closebox = function () {
                    var ibox = $element.closest('div.ibox');
                    ibox.remove();
                }
        }
    };
};

/**
 * minimalizaSidebar - Directive for minimalize sidebar
 */
function minimalizeSidebar($timeout) {
    return {
        restrict: 'A',
        template: '<a class="navbar-minimalize minimalize-styl-2 btn btn-primary " href="" ng-click="minimalize()"><i class="fa fa-bars"></i></a>',
        controller: function ($scope, $element) {
            $scope.minimalize = function () {
                $("body").toggleClass("mini-navbar");
                if (!$('body').hasClass('mini-navbar') || $('body').hasClass('body-small')) {
                    // Hide menu in order to smoothly turn on when maximize menu
                    $('#side-menu').hide();
                    // For smoothly turn on menu
                    setTimeout(
                        function () {
                            $('#side-menu').fadeIn(500);
                        }, 100);
                } else if ($('body').hasClass('fixed-sidebar')){
                    $('#side-menu').hide();
                    setTimeout(
                        function () {
                            $('#side-menu').fadeIn(500);
                        }, 300);
                } else {
                    // Remove all inline style from jquery fadeIn function to reset menu state
                    $('#side-menu').removeAttr('style');
                }
            }
        }
    };
};

function subobjectiveEditModal($timeout) {
    return {
        restrict: 'E',
        transclude: true,
        scope: {
            modalId: "@",
            modalTitle: "@",
            successButtonText: "@",
            submitCreateSubobjective: "&"
        },
        templateUrl: 'views/common/modal.html'
    };
};



/**
 *
 * Pass all functions into module
 */
angular
    .module('trackto')
    .directive('pageTitle', pageTitle)
    .directive('sideNavigation', sideNavigation)
    .directive('iboxTools', iboxTools)
    .directive('objectiveHeader', objectiveHeader)
    .directive('minimalizeSidebar', minimalizeSidebar)
    .directive('subobjectiveEditModal', subobjectiveEditModal)

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

angular
    .module('trackto')
    .controller('CreateObjectiveController', ['$scope','$window','toastr','StepsService','ObjectiveFactory', CreateObjectiveController])

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

angular
    .module('trackto')
    .controller('LoginController', ['$scope', '$window', 'toastr', 'UserFactory', LoginController])
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
        if ($scope.createSubobjective.name) {
            ObjectiveFactory.createSubobjective($scope.selected_id, $scope.createSubobjective)
                .success(function (subobjective) {
                    toastr.success("You have successfully create the subobjective: " + subobjective.name, 'Success');
                    angular.element('#createSubModal').modal('hide');
                    getObjective($scope.selected_id);
                })
                .error(function (error) {
                    if (error) {
                        toastr.error('Something went wrong and your subobjective could not be created', 'Error');
                    }
                });
        } else {
            toastr.error('A subobjective must have a name', 'Error');
        }
    }

    // Needed to kick it off on page load
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
        $scope.breakdownLabels = [];
        $scope.breakdownData = [];
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