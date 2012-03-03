class RenderAdapter
  constructor: () ->
    
class KineticJSAdapter extends RenderAdapter
  constructor: (elem, width, height, scale, x, y) ->
    console.log('KineticJSAdapter ctor')
    @stage = new Kinetic.Stage(elem, width||1000, height||450)
    @layer = new Kinetic.Layer()
    @flashLayer = new Kinetic.Layer()
    @canvas = @layer.canvas
    @context = @canvas.getContext('2d')
    @flashContext = @flashLayer.canvas.getContext('2d')
    @trackTransforms(@context)
    #@trackTransforms(@flashContext)
    
    #--------- Cached Values
    @cachedPolyAngles = {}
    @cachedPolyPoints = {}
    @pi2 = Math.PI/2
    @degToRad = Math.PI/180
    #---------------------
    
    @stage.add(@flashLayer)
    @stage.add(@layer)
    
    @customShapes = {}
    @apertures = {}
    @apertureParams = {}
    @x = x == undefined ? 10 : x
    @y = y == undefined ? 10 : y
    @scale = scale || 5
    @scaleOffset = 1
    @scaleFactor = 1.01
    @lastX = 0
    @lastY = 0
    @letters = '0123456789ABCDEF'.split('')
    @canvas.addEventListener 'mousemove', (evt) =>
      @lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft)  
      @lastY = evt.offsetY || (evt.pageY - canvas.offsetTop)
    
    @updateBounds()
  
  moveX : (val) =>  
    @context.translate((val/@scaleOffset)*0.5, 0);
    @flashContext.translate((val/@scaleOffset)*0.5, 0);
    @clear(@context)
    @clear(@flashContext)
    @updateBounds()
    
  moveY : (val) =>  
    @context.translate(0, (val/@scaleOffset)*0.5);
    @flashContext.translate(0, (val/@scaleOffset)*0.5);
    @clear(@context)
    @clear(@flashContext)
    @updateBounds()
  
  zoom : (val, center) =>
    if(center)
      pt = @context.transformedPoint(500,225)
    else
      pt = @context.transformedPoint(@lastX,@lastY)
    
    @context.translate(pt.x,pt.y)
    #console.log @context.getTransform()
    @flashContext.translate(pt.x,pt.y)
    @scaleOffset = Math.pow(@scaleFactor,val)
    @context.scale(@scaleOffset,@scaleOffset)
    @flashContext.scale(@scaleOffset,@scaleOffset)
    @context.translate(-pt.x,-pt.y)
    @flashContext.translate(-pt.x,-pt.y)
    @clear(@context)
    @clear(@flashContext)
    @drawCrosshair(pt.x,pt.y)
    @updateBounds()
    
  updateBounds: () =>
    @topLeft = @context.transformedPoint 0,0
    @botRight = @context.transformedPoint @canvas.width,@canvas.height
    
  clear: (ctx) =>
    ctx.save() 
    ctx.setTransform(1,0,0,1,0,0) 
    ctx.clearRect(0,0,ctx.canvas.width,ctx.canvas.height) 
    ctx.restore()
    #@layer.draw()
  
  visible: (x,y) =>
    return !!(x > @topLeft.x && x < @botRight.x && y > @topLeft.y && y < @botRight.y)
    
  drawCrosshair: (x,y) =>
    @context.beginPath()
    @context.moveTo(x, y-4)
    @context.lineTo(x, y+4)
    @context.moveTo(x-4, y)
    @context.lineTo(x+4, y)
    @context.lineWidth = 1
    @context.strokeStyle = "#F00"
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
      @drawPoly @flashContext,x,y,
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
    @context.strokeStyle = "#F00"
    @context.fillStyle = "#F00"
    
    if(params.type == "circle")
      width = params.outerDiam * @scale#todo - figure out proper scale
      aperture.moveTo = (x,y) =>
      aperture.lineTo = (x,y) =>
        @drawCircleLine(@context, x,y, @position.x, @position.y, width)
      aperture.flash = (x,y) =>
        @drawCircle(@flashContext, x, y, width)
    else if (params.type == "rectangle")
      aperture.moveTo = (x,y) =>
        #console.log "rectangle moveTo #{x}, #{y}"
      aperture.lineTo = (x,y) =>
        console.log "rectangle lineTo #{x}, #{y}"
      aperture.flash = (x,y) =>
        #console.log "rectangle flash #{x}, #{y}"
        @drawRect @flashContext, x,y,params.outerWidth*@scale, params.outerHeight*@scale
    else if (params.type == "polygon")
      aperture.moveTo = (x,y) =>
        console.log "polygon moveTo #{x}, #{y}"
      aperture.lineTo = (x,y) =>
        console.log "polygon lineTo #{x}, #{y}"
      aperture.flash = (x,y) =>
        console.log "polygon flash #{x}, #{y}"
    else if (@customShapes[params.type])
      aperture.moveTo = (x,y) =>
        console.log "custom moveTo #{x}, #{y}"
      aperture.lineTo = (x,y) =>
        console.log "custom lineTo #{x}, #{y}"
      aperture.flash = @customShapes[params.type].flash
    
    @apertureParams[params.code] = params
        
  createContext: (width,height) =>
    tmpCanvas = document.createElement('canvas')
    tmpCanvas.width = width
    tmpCanvas.height = height
    tmpCanvas.getContext('2d')
  
  polyAngles: memoize (sides, rot) ->
    #console.log "polyAngles #{sides},#{rot}"
    angles = []
    pi2_s = (2 * Math.PI) / sides
    rotRad = rot*(Math.PI/180)

    for i in [0..sides]
      angles[i] = {
        cos: Math.cos((pi2_s * i)+rotRad)
        sin: Math.sin((pi2_s * i)+rotRad)
      }
      
  polyPoints: memoize (x,y,d,sides,rot) ->
    #console.log "polyPoints #{x} #{y} #{d} #{sides} #{rot}"
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
      ctx.fillStyle = "#0FF"
      ctx.strokeStyle = "#0FF"

      points = @polyPoints x,y,d,sides,rot
      ctx.moveTo points[0].x, points[0].y
      for i in [1..sides]
        ctx.lineTo points[i].x, points[i].y

      ctx.fill()
      
  drawRect: (ctx,x,y,w,h) =>
    if(@visible x, y)
      ctx.save()
      ctx.fillStyle = "#FF0"
      ctx.strokeStyle = "#FF0"
      ctx.fillRect(x-w/2, y-h/2, w, h);
      ctx.fill()
      ctx.restore()
  
  cos: memoize (rads, offset, minus) ->
    if minus
      return Math.cos(rads - offset)
    else
      return Math.cos(rads + offset)
  
  sin: memoize (rads, offset, minus) ->
    if minus
      return Math.sin(rads - offset)
    else
      return Math.sin(rads + offset)
      
  atan2: memoize (dy, dx) ->
    return Math.atan2(dy, dx)
          
  circPoints: memoize (x1, y1, x2, y2, r) ->
    dx = x2 - x1
    dy = y2 - y1
    points = { x:{1:{},2:{}}, y: {1:{},2:{}} }
    points.rads = @atan2(dy, dx)
    #points.x[1][1] = x1 + r * @cos(points.rads, @pi2, true)
    #points.y[1][1] = y1 + r * @sin(points.rads, @pi2, true)
    points.x[1][2] = x1 + r * @cos(points.rads, @pi2, false)
    points.y[1][2] = y1 + r * @sin(points.rads, @pi2, false)
    points.x[2][1] = x2 + r * @cos(points.rads, @pi2, true)
    points.y[2][1] = y2 + r * @sin(points.rads, @pi2, true)
    #points.x[2][2] = x2 + r * @cos(points.rads, @pi2, false)
    #points.y[2][2] = y2 + r * @sin(points.rads, @pi2, false)
    return points
  
  drawCircleLine: (ctx,x1,y1,x2,y2,d) =>
    if(@visible x1, y1 || @visible x2, y2)
      ctx.beginPath()
      ctx.fillStyle = "#F00"
      ctx.strokeStyle = "#F00"
      r = d/2
      points = @circPoints x1,y1,x2,y2,r
    
      ctx.arc(x1, y1, r, points.rads + @pi2, points.rads - @pi2, false)
      ctx.lineTo points.x[2][1], points.y[2][1]
 
      ctx.arc(x2, y2, r, points.rads - @pi2, points.rads + @pi2, false)
      ctx.lineTo points.x[1][2], points.y[1][2]
      ctx.lineWidth = 1
      ctx.fill()
          
  drawCircle: (ctx,x,y,d) =>
    if(@visible x,y)
      ctx.beginPath()
      ctx.fillStyle = "#F00"
      ctx.strokeStyle = "#F00"
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
    if(!@firstmove)
      @firstmove = {x:xt,y:yt}
  
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
      if(@firstmove)
        @moveTo(@firstmove) 
      @context.stroke()
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