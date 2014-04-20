App.controller 'ProjectsCtrl', ['$scope', 'Project', ($scope, Project) ->
  $scope.project = Project.query()
]