class RenderAdapter
  constructor: () ->
    
class KineticJSAdapter extends RenderAdapter
  constructor: (elem, width, height, scale, x, y) ->
    @stage = new Kinetic.Stage(elem, width||1000, height||450)
    @layer = new Kinetic.Layer()
    @canvas = @layer.canvas
    @context = @canvas.getContext('2d')
    @trackTransforms(@context)
    
    #--------- Cached Values
    @pi2 = Math.PI/2
    @degToRad = Math.PI/180
    #---------------------
    
    @stage.add(@layer)
    
    @layers = []
    @customShapes = {}
    @apertures = {}
    @apertureParams = {}
    
    @x = x == undefined ? 10 : x
    @y = y == undefined ? 10 : y
    @scale = scale || 5
    @scaleFactor = 1.01
    @minPixels = 3
    @lastX = 0
    @lastY = 0
    @letters = '0123456789ABCDEF'.split('')
    
    
    window.addEventListener('resize', @resize, false)
    
    @canvas.addEventListener 'mousemove', (evt) =>
      #console.log evt
      #console.log @canvas.offsetLeft
      #console.log @canvas.offsetTop
      @lastX = evt.offsetX || (evt.pageX - @canvas.offsetLeft)  
      @lastY = evt.offsetY || (evt.pageY - @canvas.offsetTop)
    
    @resize()
  
  resize: () =>
    @context.save() 
    @context.setTransform(1,0,0,1,0,0)
    #console.log $('body').width(), $('body').height()
    #$(@canvas).width($('.panel').width())
    #$(@canvas).height($('.panel').height())
    #@canvas.width = $('.panel').width()
    #@canvas.height = $('.panel').height()
    @context.restore()
    @updateBounds()
    @render()
  
  setWidth: () =>
    
  
  addLayer: (commands, color) =>
    layer = { commands: commands, color:color, name:name }
    @layers.push layer
    @updateBounds()
    @render()
      
  render: () =>
    start = new Date;
    for i,layer of @layers
      @color = layer.color
      for j,command of layer.commands
        this[command.command](command) if command != null && this[command.command]
    end = new Date;
    #console.log("Render Time: #{end - start}")
    @context.fillStyle = "#0FF"
    @context.font = "bold #{(@detail/@minPixels) *12}px sans-serif"
    pt = @context.transformedPoint 20,20
    @context.fillText(end - start, pt.x, pt.y)
  
  moveX : (val) =>  
    # scale mouse move based on zoom
    @context.translate(val*(@detail/@minPixels), 0);
    @clear(@context)
    @updateBounds()
    @render()
    
  moveY : (val) =>  
    # scale mouse move based on zoom
    @context.translate(0, val*(@detail/@minPixels));
    @clear(@context)
    @updateBounds()
    @render()
  
  zoom : (val, center) =>
    if(center)
      pt = @context.transformedPoint(@canvas.width/2,@canvas.height/2)
    else
      pt = @context.transformedPoint(@lastX,@lastY)
    
    @context.translate(pt.x,pt.y)
    scale = Math.pow(@scaleFactor,val)
    @context.scale(scale,scale)
    @context.translate(-pt.x,-pt.y)
    @clear(@context)
    @drawCrosshair(pt.x,pt.y)
    @updateBounds()
    @render()
    
  updateBounds: () =>
    # prevents rendering of offscreen geometry
    @topLeft = @context.transformedPoint 0,0
    detail = @context.transformedPoint @minPixels,0
    @detail = detail.x - @topLeft.x
    @botRight = @context.transformedPoint @canvas.width,@canvas.height
    
  clear: (ctx) =>
    ctx.save() 
    ctx.setTransform(1,0,0,1,0,0) 
    ctx.clearRect(0,0,ctx.canvas.width,ctx.canvas.height) 
    ctx.restore()
  
  visible: (x,y) =>
    return !!(x > @topLeft.x && x < @botRight.x && y > @topLeft.y && y < @botRight.y)
    
  drawCrosshair: (x,y) =>
    @context.beginPath()
    @context.moveTo(x, y-4)
    @context.lineTo(x, y+4)
    @context.moveTo(x-4, y)
    @context.lineTo(x+4, y)
    @context.lineWidth = 1
    @context.strokeStyle = @color
    @context.stroke()
    @context.closePath()
        
  multiQuad: (params) =>
  inches: (params) =>
  offset: (params) =>
  formatSpec: (params) =>
  imagePolarity: (params) =>
  layerPolarity: (params) =>
  
  macro: (params) =>
    @customShapes[params.name] = params
    @customShapes[params.name].flash = (x,y,p) =>
      @drawPoly @context,x,y,
      (p.param1||1)*(params.diameter||1) * @scale,
      params.sides,
      params.rotation
      
  apertureDef: (params) =>
    if(!@context.drawingPath)
      @context.beginPath()  
      @context.drawingPath = true
    #define aperture
    aperture = { lineWidth: params.outerDiam * @scale }
    @apertures[params.code] = aperture
    @aperture = params.code
    
    @context.lineWidth = aperture.lineWidth;
    @context.strokeStyle = @color
    @context.fillStyle = @color
    
    if(params.type == "circle")
      width = params.outerDiam * @scale
      aperture.moveTo = (x,y) =>
      aperture.lineTo = (x,y) =>
        @drawCircleLine(@context, x,y, @position.x, @position.y, width)
      aperture.flash = (x,y) =>
        @drawCircle(@context, x, y, width)
    else if (params.type == "rectangle")
      aperture.moveTo = (x,y) =>
        
      aperture.lineTo = (x,y) =>
      aperture.flash = (x,y) =>
        
        @drawRect @context, x,y,params.outerWidth*@scale, params.outerHeight*@scale
    else if (params.type == "polygon")
      aperture.moveTo = (x,y) =>
      aperture.lineTo = (x,y) =>
      aperture.flash = (x,y) =>
    else if (@customShapes[params.type])
      aperture.moveTo = (x,y) =>
      aperture.lineTo = (x,y) =>
      aperture.flash = @customShapes[params.type].flash
    
    @apertureParams[params.code] = params
        
  createContext: (width,height) =>
    tmpCanvas = document.createElement('canvas')
    tmpCanvas.width = width
    tmpCanvas.height = height
    tmpCanvas.getContext('2d')
  
  polyAngles: (sides, rot) ->
    angles = []
    pi2_s = (2 * Math.PI) / sides
    rotRad = rot*@degToRad

    for i in [0..sides]
      angles[i] = {
        cos: @cos((pi2_s * i)+rotRad)
        sin: @sin((pi2_s * i)+rotRad)
      }
      
  polyPoints: memoize (x,y,d,sides,rot) ->
    r = d/2
    angles = @polyAngles sides, rot
    points = []
    for i in [0..sides]
      xi = x + r * angles[i].cos
      yi = y + r * angles[i].sin
      points[i] = {x:xi,y:yi}
      
  drawPoly: (ctx,x,y,d,sides, rot) =>
    if(@visible x,y)
      ctx.beginPath()
      ctx.fillStyle = @color
      ctx.strokeStyle = @color

      points = @polyPoints x,y,d,sides,rot
      ctx.moveTo points[0].x, points[0].y
      for i in [1..sides]
        ctx.lineTo points[i].x, points[i].y

      ctx.fill()
      
  drawRect: (ctx,x,y,w,h) =>
    if(@visible x, y)
      ctx.save()
      ctx.fillStyle = @color
      ctx.strokeStyle = @color
      ctx.fillRect(x-w/2, y-h/2, w, h);
      ctx.fill()
      ctx.restore()
  
  cos: memoize1 Math.cos
  
  sin: memoize1 Math.sin
      
  atan2: memoize2 (dy, dx) ->
    return Math.atan2(dy, dx)
          
  circPoints: memoize (x1, y1, x2, y2, r) ->
    dx = x2 - x1
    dy = y2 - y1
    points = { x:{1:{},2:{}}, y: {1:{},2:{}} }
    points.rads = @atan2(dy, dx)
    points.x[1][1] = x1 + r * @cos(points.rads - @pi2)
    points.y[1][1] = y1 + r * @sin(points.rads - @pi2)
    points.x[1][2] = x1 + r * @cos(points.rads + @pi2)
    points.y[1][2] = y1 + r * @sin(points.rads + @pi2)
    points.x[2][1] = x2 + r * @cos(points.rads - @pi2)
    points.y[2][1] = y2 + r * @sin(points.rads - @pi2)
    #points.x[2][2] = x2 + r * @cos(points.rads + @pi2)
    #points.y[2][2] = y2 + r * @sin(points.rads + @pi2)
    return points
  
  arcPoints: memoize (x, y, r, start, end, clockwise, segments) ->
    if clockwise
      rads_per = (start - end)/segments
    else
      rads_per = (end - start)/segments
    points = []
    for i in [0..segments]
      point = {}
      point.x = x + r * @cos(start + (i * rads_per))
      point.y = y + r * @sin(start + (i * rads_per))
      #console.log point
      points.push point
    return points
    
  drawArc: (ctx, x, y, r, start, end, clockwise) =>
    points = @arcPoints x, y, r, start, end, clockwise, 6
    #console.log points
    for i,p of points
      #console.log p
      ctx.lineTo p.x, p.y
  
  drawCircleLine: (ctx,x1,y1,x2,y2,d) =>
    ctx.lineCap = "square";
    if(@visible x1, y1 || @visible x2, y2)
      if(d<@detail)
        ctx.beginPath()
        ctx.fillStyle = "#0F0"#@color
        ctx.strokeStyle = "#0F0"#@color
        ctx.moveTo x2, y2
        ctx.lineTo x1, y1
        ctx.lineWidth = 1.5
        ctx.stroke()
        ctx.closePath()
      else
        ctx.beginPath()
        ctx.fillStyle = @color
        ctx.strokeStyle = "#FFF"
        r = d/2
        points = @circPoints x1,y1,x2,y2,r
        
        ctx.moveTo points.x[1][1], points.y[1][1]
        #ctx.lineTo points.x[1][1], points.y[1][1]
        #ctx.lineTo points.x[1][2], points.y[1][2]
        #ctx.lineTo points.x[2][2], points.y[2][2]
        #ctx.lineTo points.x[2][1], points.y[2][1]
        
        #ctx.arc(x1, y1, r, points.rads + @pi2, points.rads - @pi2, false)
        @drawArc ctx, x1, y1, r, points.rads + @pi2, points.rads - @pi2, true
        ctx.lineTo points.x[2][1], points.y[2][1]
 
        #ctx.arc(x2, y2, r, points.rads - @pi2, points.rads + @pi2, false)
        @drawArc ctx, x2, y2, r, points.rads - @pi2, points.rads + @pi2, false
        ctx.lineTo points.x[1][2], points.y[1][2]
        
        ctx.lineWidth = 1
        ctx.fill()
        #ctx.stroke()
          
  drawCircle: (ctx,x,y,d) =>
    if(@visible x,y)
      ctx.beginPath()
      ctx.fillStyle = @color
      ctx.strokeStyle = @color
      ctx.arc(x, y, d/2, 0, Math.PI*2, false)
      ctx.fill()
      
  randomColor: () ->
    color = '#'
    for i in [1..6]
      color += @letters[Math.round(Math.random() * 15)]
    return color

  select: (params) =>
    @aperture = params.code
    @context.lineWidth = @apertures[@aperture].lineWidth || 1
    
  moveTo: (params) =>
    xt = @transformX params.x
    yt = @transformY params.y
    @position = {x:xt,y:yt}
    @apertures[@aperture].moveTo xt, yt, @apertureParams[@aperture]
  
  transformX: (x) =>
    (x*@scale)+@x
    
  transformY: (y) =>
    @canvas.height - ((y * @scale) + @y)
    
  drawTo: (params) =>
    xt = @transformX params.x
    yt = @transformY params.y
    @apertures[@aperture].lineTo xt, yt, @apertureParams[@aperture]
    @position = {x:xt,y:yt}
    
  flash: (params) =>
    xt = @transformX params.x
    yt = @transformY params.y
    @apertures[@aperture].flash xt, yt, @apertureParams[@aperture]
    @position = {x:xt,y:yt}
        
  end: (params) =>
    if(@context.drawingPath)
      @context.drawingPath = false
    
  # Adds ctx.getTransform() - returns an SVGMatrix
  # Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  trackTransforms: (ctx) =>
  	svg = document.createElementNS("http://www.w3.org/2000/svg",'svg')
  	xform = svg.createSVGMatrix()
  	ctx.getTransform = () ->
  	  return xform

  	savedTransforms = [];
  	save = ctx.save
  	ctx.save = () ->
  		savedTransforms.push(xform.translate(0,0))
  		save.call(ctx)
  	
  	restore = ctx.restore
  	ctx.restore = () ->
  		xform = savedTransforms.pop()
  		restore.call(ctx)

  	scale = ctx.scale
  	ctx.scale = (sx,sy) ->
  		xform = xform.scaleNonUniform(sx,sy)
  		scale.call(ctx,sx,sy)
  		
  	rotate = ctx.rotate
  	ctx.rotate = (radians) ->
  		xform = xform.rotate(radians*180/Math.PI)
  		rotate.call(ctx,radians);
  		
  	translate = ctx.translate
  	ctx.translate = (dx,dy) ->
  		xform = xform.translate(dx,dy)
  		translate.call(ctx,dx,dy)
  		
  	transform = ctx.transform
  	ctx.transform = (a,b,c,d,e,f) ->
  		m2 = svg.createSVGMatrix()
  		m2.a=a 
  		m2.b=b 
  		m2.c=c
  		m2.d=d
  		m2.e=e
  		m2.f=f
  		xform = xform.multiply(m2)
  		transform.call(ctx,a,b,c,d,e,f)
  		
  	setTransform = ctx.setTransform
  	ctx.setTransform = (a,b,c,d,e,f) ->
  		xform.a = a
  		xform.b = b
  		xform.c = c
  		xform.d = d
  		xform.e = e
  		xform.f = f
  		setTransform.call(ctx,a,b,c,d,e,f)
  	
  	pt  = svg.createSVGPoint()
  	ctx.transformedPoint = (x,y) ->
  		pt.x=x
  		pt.y=y
  		pt.matrixTransform(xform.inverse())
    
class RaphaelJSAdapter extends RenderAdapter
  constructor: ->
    
class ThreeJSAdapter extends RenderAdapter
  constructor: ->
    
    
window.KineticJSAdapter = KineticJSAdapter