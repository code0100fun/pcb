Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.EditView extends Backbone.View
  template : JST["backbone/templates/boards/edit"]

  events :
    "submit #edit-board" : "update"
    "submit #edit-board" : "update"
    
  initialize : () ->
    
  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (board) =>
        @model = board
        window.location.hash = "/#{@model.id}"
    )
  
  buildAnchor : (curveLayer, anchorsLayer, x, y) =>
    anchor = new Kinetic.Circle
      x: 0
      y: 0
      radius: 5
      stroke: "#666"
      fill: "#ddd"
      strokeWidth: 2

    anchor.setPosition(x, y)
    anchor.draggable(true)

    # set curve points on dragmove
    anchor.on "dragmove", () =>
      @drawCurves(curveLayer)

    # add hover styling
    anchor.on "mouseover", () ->
      document.body.style.cursor = "pointer"
      this.setStrokeWidth(4)
      anchorsLayer.draw()
    anchor.on "mouseout", () ->
      document.body.style.cursor = "default"
      this.setStrokeWidth(2)
      anchorsLayer.draw()

    anchorsLayer.add(anchor)
    return anchor
    
  drawCurves : (curveLayer) =>
    context = curveLayer.getContext()
    curveLayer.clear()

    # draw quad
    quad = curveLayer.quad

    # draw curve
    context.beginPath()
    context.moveTo(quad.start.x, quad.start.y)
    context.lineTo(quad.control.x, quad.control.y)
    context.lineTo(quad.end.x, quad.end.y)
    context.strokeStyle = "#ccc"
    context.lineWidth = 2
    context.stroke()
    context.closePath()

    # draw connectors
    context.beginPath()
    context.moveTo(quad.start.x, quad.start.y)
    context.quadraticCurveTo(quad.control.x, quad.control.y, quad.end.x, quad.end.y)
    context.strokeStyle = "red"
    context.lineWidth = 4
    context.stroke()

    # draw bezier
    bezier = curveLayer.bezier

    # draw curve
    context.beginPath()
    context.moveTo(bezier.start.x, bezier.start.y)
    context.lineTo(bezier.control1.x, bezier.control1.y)
    context.lineTo(bezier.control2.x, bezier.control2.y)
    context.lineTo(bezier.end.x, bezier.end.y)
    context.strokeStyle = "#ccc"
    context.lineWidth = 2
    context.stroke()
    context.closePath()

    # draw connectors
    context.beginPath()
    context.moveTo(bezier.start.x, bezier.start.y)
    context.bezierCurveTo(bezier.control1.x, bezier.control1.y, bezier.control2.x, bezier.control2.y, bezier.end.x, bezier.end.y)
    context.strokeStyle = "blue"
    context.lineWidth = 4
    context.stroke()
      
  getCursorPosition : (elem, e) ->
    top = 0
    left = 0
    while (elem && elem.tagName != 'BODY')
      top += elem.offsetTop
      left += elem.offsetLeft
      elem = elem.offsetParent
    #console.log "top:#{top}, left:#{left}"
    mouseX = e.clientX - left + window.pageXOffset
    mouseY = e.clientY - top + window.pageYOffset
    { x: e.layerX, y: e.layerY}
      
  render : ->
    $(@el).html(@template(@model.toJSON() ))
    this.$("form").backboneLink(@model)
    
    @stage = new Kinetic.Stage(this.$('#canvas')[0], 500, 400) if !@stage
    @layer = new Kinetic.Layer() if !@layer
    
    @backgroundlayer = new Kinetic.Layer();
    background = new Kinetic.Shape () ->
      context = this.getContext()
      context.beginPath()
      context.lineWidth = 1
      context.strokeStyle = "black"
      context.fillStyle = "#000"
      context.moveTo(0, 0)
      context.lineTo(500, 0)
      context.lineTo(500, 400)
      context.lineTo(0, 400)
      context.closePath()
      context.fill()
      context.stroke()
      
    curveLayer = new Kinetic.Layer()
    anchorsLayer = new Kinetic.Layer()

    #curveLayer.quad = 
    #  start: @buildAnchor(curveLayer, anchorsLayer, 60, 30)
    #  control: @buildAnchor(curveLayer, anchorsLayer, 240, 110)
    #  end: @buildAnchor(curveLayer, anchorsLayer, 80, 160)

    #curveLayer.bezier =
    #  start: @buildAnchor(curveLayer, anchorsLayer, 280, 20)
    #  control1: @buildAnchor(curveLayer, anchorsLayer, 530, 40)
    #  control2: @buildAnchor(curveLayer, anchorsLayer, 480, 150)
    #  end: @buildAnchor(curveLayer, anchorsLayer, 300, 150)
    background.on "mousedown", (e) =>
      #console.log @stage.backstageLayer.canvas
      pos = @getCursorPosition(@stage.backstageLayer.canvas, e)
      anchor1 = @buildAnchor(curveLayer, anchorsLayer, pos.x, pos.y)
      anchorsLayer.add anchor1
      @anchor2 = @buildAnchor(curveLayer, anchorsLayer, pos.x, pos.y)
      anchorsLayer.add @anchor2
      anchorsLayer.draw()
      
    background.on "mousemove", (e) =>
      if(@anchor2)
        console.log @anchor2
        pos = @getCursorPosition(@stage.backstageLayer.canvas, e)
        @anchor2.x = pos.x
        @anchor2.y = pos.y
        anchorsLayer.draw()
    
    background.on "mouseup", (e) =>
      @anchor2 = null
     
    # so you can't drag off screen
    @stage.on "mouseout", () =>
      #@drawCurves(curveLayer)
      anchorsLayer.draw()
        
    @layer.add(background)
    @stage.add(@backgroundlayer)
    @stage.add(@layer)
    @stage.add(curveLayer)
    @stage.add(anchorsLayer)

    #@drawCurves(curveLayer);


    return this
  