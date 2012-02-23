class Pcb.Views.BoardsIndex extends Backbone.View

  template: JST['boards/index']
  
  initialize: ->
    @collection.on('reset', @render)
    
  render: =>  
    @stage = new Kinetic.Stage(@el, 500, 500) if !@stage
    @layer = new Kinetic.Layer() if !@layer
    shape = new Kinetic.Shape () ->
      context = this.getContext()
      context.beginPath()
      context.lineWidth = 4
      context.strokeStyle = "black"
      context.fillStyle = "#00D2FF"
      context.moveTo(230, 50)
      context.lineTo(360, 80)
      context.lineTo(260, 170)
      context.closePath()
      context.fill()
      context.stroke()
    
    shape.on "mouseover", () -> document.body.style.cursor = "pointer"
    shape.on "mouseout", () -> document.body.style.cursor = "default"
      
    @layer.add(shape)
    @stage.add(@layer)
    shape.draggable(true)  
    
    this