class Pcb.Routers.Layers extends Backbone.Router
  routes:
    'layers': 'index'
    'layers/:id': 'show'
  
  initialize: ->
    @collection = new Pcb.Collections.Layers()
    @collection.fetch()
    
  index: ->
    view = new Pcb.Views.LayersIndex(collection: @collection)
    $('#container').html(view.render().el)
    
  show: (id) ->
    alert "Layer #{id}"

