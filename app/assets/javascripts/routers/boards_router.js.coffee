class Pcb.Routers.Boards extends Backbone.Router
  routes:
    'boards': 'index'
    'boards/:id': 'show'
    
  initialize: ->
    @collection = new Pcb.Collections.Boards()
    @collection.fetch()
      
  index: ->
    view = new Pcb.Views.BoardsIndex(collection: @collection)
    $('#container').html(view.render().el)
    
  show: (id) ->
    alert "Board #{id}"