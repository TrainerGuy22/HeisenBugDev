window.App = angular.module('HeisenBugDev', ['ngResource'])

App.config(['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when('/projects/:projectId', {
      templateUrl: 'something.html',
      controller: 'ProjectsCtrl'
    })
])
