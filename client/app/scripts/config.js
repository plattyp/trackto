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