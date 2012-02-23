class Pcb.Views.LayersIndex extends Backbone.View

  template: JST['layers/index']
  
  initialize: ->
    @collection.on('reset', @render, this)
    
  render: ->
    $(@el).html(@template(layers: @collection))
    this