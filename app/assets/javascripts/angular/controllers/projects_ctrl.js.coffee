App.controller 'ProjectsCtrl', ['$scope', '$routeParams', 'Project', ($scope, $routeParams, Project) ->
  console.log $routeParams
  $scope.project = Project.query({id: $routeParams.projectId})
]