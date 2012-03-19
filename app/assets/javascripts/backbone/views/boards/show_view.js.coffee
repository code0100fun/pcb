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
    "mousewheel .panel canvas" : "mouseWheel"
    "mousedown .panel canvas"  : "mouseDown"
    "mousemove .panel canvas"  : "mouseMove"
    "mouseup .panel canvas"    : "mouseUp"
    "mouseleave .panel canvas" : "mouseUp"
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
    $(@el).css({height:'100%'})
    @device.render()
    return this
    
  initialize : () =>
    $(@el).html(@template({name:'test'}))
    @device = new KineticJSAdapter(this.$('.panel')[0], 800, 450, 200, 1200, 1200)
    @parser = new GerberParser()
    @colors = ["#F00", "#0FF", "#00F", "#FF0", "#FFF"]
    @color = 0
  
  loadFile: (evt) =>
    #console.log JSON.stringify evt.originalEvent
    file = evt.originalEvent.srcElement.files[0]
    #console.log "start"
    #console.log file
    reader = new FileReader()
    reader.onload = (e) =>
        @lines = e.target.result.split(/\s+/m)
        commands = @parser.parse(@lines)
        # add layer to device passing commands for new layer
        @device.addLayer commands, @colors[@color++]
        @render()
        
    reader.readAsText(file)