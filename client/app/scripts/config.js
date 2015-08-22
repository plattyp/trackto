/* Router */
function config($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/index/dashboard");

    $stateProvider
        .state('index', {
            abstract: true,
            url: "/index",
            templateUrl: "views/common/content.html",
            resolve: {
              auth: function($auth) {
                return $auth.validateUser();
              }
            }
        })
        .state('index.main', {
            url: "/main",
            templateUrl: "views/main.html",
            data: { pageTitle: 'Example view' }
        })
        .state('index.minor', {
            url: "/minor",
            templateUrl: "views/minor.html",
            data: { pageTitle: 'Example view' }
        })
        .state('index.dashboard', {
            url: "/dashboard",
            templateUrl: "views/dashboard.html",
            data: { pageTitle: 'Dashboard' }
        })
        .state('index.objective', {
            url: "/objectives/:objectiveId",
            templateUrl: "views/objective_dashboard.html",
            data: {pageTitle: 'Objective' }
        })
        .state('index.new_objective', {
            url: "/objective/new",
            templateUrl: "views/new_objective.html",
            data: {pageTitle: 'Create Objective' }
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