class RenderAdapter
  constructor: () ->
    
class KineticJSAdapter extends RenderAdapter
  constructor: (elem) ->
    @stage = new Kinetic.Stage(elem, 1000, 400)
    @layer = new Kinetic.Layer()
    @context = @layer.getContext()
    @canvas = @layer.getCanvas()
    
    @stage.add(@layer)
    
    @context.beginPath()
    @zoom = 13
    @xScroll = 100
    @yScroll = 20
    
  multiQuad: (params) =>
    #console.log "multiQuad"
  inches: (params) =>
    #console.log "inches"
  offset: (params) =>
    #console.log "offset"
  formatSpec: (params) =>
    #console.log "formatSpec"
  imagePolarity: (params) =>
    #console.log "imagePolarity"
  layerPolarity: (params) =>
    #console.log "layerPolarity"
  macro: (params) =>
    #console.log "macro"
  apertureDef: (params) =>
    #console.log "apertureDef"
  select: (params) =>
    #console.log "select"
    
  moveTo: (params) =>
    x = (params.x*@zoom)+@xScroll
    y = @canvas.height - ((params.y * @zoom) + @yScroll)
    #console.log "moveTo #{x} #{y} #{@canvas.height}"
    @context.moveTo(x, y)
    
  drawTo: (params) =>
    x = (params.x*@zoom)+@xScroll
    y = @canvas.height - ((params.y * @zoom) + @yScroll)
    #console.log "drawTo #{x} #{y} #{@canvas.height}"
    @context.lineTo(x, y)
    
  end: (params) =>
    #console.log "end"
    #@context.lineWidth = 4
    #@context.strokeStyle = "#000"
    @context.closePath()
    @context.stroke()
    
class RaphaelJSAdapter extends RenderAdapter
  constructor: ->
    
class ThreeJSAdapter extends RenderAdapter
  constructor: ->
    
    
window.KineticJSAdapter = KineticJSAdapter