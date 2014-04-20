App.factory 'Project', ['$resource', ($resource) ->
  $resource '/projects:id.json', id: '@id'
]