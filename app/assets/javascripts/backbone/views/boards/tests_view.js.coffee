Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.TestsView extends Backbone.View
  template: JST["backbone/templates/boards/tests"]

  render: ->
    $(@el).html(@template())
    
    @circleApertureLine()
    @circleApertureShape()
    @flashPolygon()
    @flashRect()
    @circle()
    
    return this
  
  circle: () =>
    canvas = @createCanvas("Circle")
    device = new KineticJSAdapter(canvas[0], 100, 100, 1, 0, 0)

    commands = [
      {"command":"apertureDef","code":10,"type":"circle","outerDiam":100}
      {"command":"select","code":10}
      {"command":"moveTo","x":50,"y":50}
      {"command":"drawTo","x":50,"y":50}
      {"command":"end"}
    ]
    @sendCommands commands, device
    
  circleApertureLine: () =>
    canvas = @createCanvas("Circle Aperture")
    device = new KineticJSAdapter(canvas[0], 100, 100, 1, 0, 0)
    
    commands = [
      {"command":"apertureDef","code":10,"type":"circle","outerDiam":10}
      {"command":"select","code":10}
      {"command":"moveTo","x":30,"y":30}
      {"command":"drawTo","x":70,"y":70}
      {"command":"end"}
    ]
    @sendCommands commands, device
  
  circleApertureShape: () =>
    canvas = @createCanvas("Circle Aperture Shape")
    device = new KineticJSAdapter(canvas[0], 100, 100, 1, 0, 0)

    commands = [
      {"command":"apertureDef","code":10,"type":"circle","outerDiam":10}
      {"command":"select","code":10}
      {"command":"moveTo","x":30,"y":30}
      {"command":"drawTo","x":70,"y":30}
      {"command":"drawTo","x":70,"y":70}
      {"command":"drawTo","x":30,"y":70}
      {"command":"drawTo","x":30,"y":30}
      {"command":"end"}
    ]
    @sendCommands commands, device
  
  drawGrid: (device) =>
    commands = [
      {"command":"apertureDef","code":10,"type":"circle","outerDiam":1}
      {"command":"select","code":10}
      {"command":"moveTo","x":0,"y":50}
      {"command":"drawTo","x":100,"y":50}
      {"command":"moveTo","x":50,"y":0}
      {"command":"drawTo","x":50,"y":100}
      {"command":"end"}
    ]
    @sendCommands commands, device
  
  flashPolygon: () =>
    canvas = @createCanvas('Flash Polygon')
    device = new KineticJSAdapter(canvas[0], 100, 100, 1, 0, 0)

    commands = [
      {"command":"macro","name":"OC8","primative":"polygon","exposure":true,"sides":8,"x":0,"y":0,"diameter":50,"rotation":22.5}
      {"command":"apertureDef","code":11,"type":"OC8","param1":1}
      {"command":"select","code":11}
      {"command":"flash","x":50,"y":50}
      {"command":"end"}
    ]
    @sendCommands commands, device
    
    #@drawGrid device
  
  flashRect: () =>
    canvas = @createCanvas('Flash Rectangle')
    device = new KineticJSAdapter(canvas[0], 100, 100, 1, 0, 0)

    commands = [
      {"command":"apertureDef","code":10,"type":"rectangle","outerWidth":40, "outerHeight":40, "innerWidth":20, "innerHeight":20}
      {"command":"select","code":10}
      {"command":"flash","x":50,"y":50}
      {"command":"end"}
    ]
    @sendCommands commands, device
        
  createCanvas: (title) =>
    canvas = $('<div class="testCanvas"/>')
    container = $('<div class="testBox"/>')
    $("<p>#{title}</p>").appendTo(container)
    container.appendTo(@el)
    canvas.appendTo(container)
    
   
  sendCommands: (commands, device) =>
    device.addLayer commands, "#FFF"
    device.render()
    
