Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.ShowView extends Backbone.View
  template: JST["backbone/templates/boards/show"]
  
  events :
    "click #zoomIn"    : "zoomIn"
    "click #zoomOut"   : "zoomOut"
    "click #moveLeft"  : "moveLeft"
    "click #moveRight" : "moveRight"
    "click #moveUp"    : "moveUp"
    "click #moveDown"  : "moveDown"
    "mousewheel #canvas canvas" : "mouseWheel"
    "mousedown #canvas canvas"  : "mouseDown"
    "mousemove #canvas canvas"  : "mouseMove"
    "mouseup #canvas canvas"    : "mouseUp"
    "mouseleave #canvas canvas" : "mouseUp"
    "change #file" : "loadFile"
  mouseDown: (e) =>  
    @draging = true
    @x = e.clientX
    @y = e.clientY
  mouseMove: (e) =>  
    if(@draging)  
      @device.moveX(e.clientX - @x)
      @device.moveY(e.clientY - @y)
      @x = e.clientX
      @y = e.clientY
      @render()
    
  mouseUp: (e) =>  
    @draging = false
  mouseWheel: (e) =>
    e.preventDefault()
    delta = e.originalEvent.wheelDelta
    @device.zoom(delta)
    @render()
    return false
      
  zoomIn: =>
    @device.zoom(20,true)
    @render()
  zoomOut: =>
    @device.zoom(-20,true)
    @render()
  moveLeft: =>
    @device.moveX(-20)
    @render()
  moveRight: =>
    @device.moveX(20)
    @render()
  moveUp: =>
    @device.moveY(-20)
    @render()
  moveDown: =>
    @device.moveY(20)
    @render()
    
  render: =>
    #console.log "render"
    #@device.clear()
    #console.log JSON.stringify @commands
    for i,command of @commands
      @device[command.command](command) if command != null && @device[command.command]
    return this
    
  initialize : () =>
    #@loadLines()
    $(@el).html(@template({name:'test'}))
    @device = new KineticJSAdapter(this.$('#canvas')[0], 1000, 450, 15, 100, 100)
    @parser = new GerberParser()
    #@commands = @parser.parse(@lines)
  
  loadFile: (evt) =>
    file = evt.originalEvent.srcElement.files[0]
    #console.log "start"
    #console.log file
    reader = new FileReader()
    reader.onload = (e) =>
        # Here's where you would parse the first few lines of the CSV file
        #console.log e.target.result
        @lines = e.target.result.split(/\s+/m)
        #console.log @lines
        @commands = @parser.parse(@lines)
        @render()
        
    reader.readAsText(file)