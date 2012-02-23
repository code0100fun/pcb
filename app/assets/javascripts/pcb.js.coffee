window.Pcb =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: -> 
    new Pcb.Routers.Boards()
    new Pcb.Routers.Layers()
    Backbone.history.start()

$(document).ready ->
  Pcb.init()
