class RenderAdapter
  constructor: () ->
    
class KineticJSAdapter extends RenderAdapter
  constructor: (elem) ->
    console.log('KineticJSAdapter ctor')
    @stage = new Kinetic.Stage(elem, 1000, 450)
    @layer = new Kinetic.Layer()
    @flashLayer = new Kinetic.Layer()
    @canvas = @layer.canvas
    @context = @canvas.getContext('2d')
    @flashContext = @flashLayer.canvas.getContext('2d')
    @trackTransforms(@context)
    #@trackTransforms(@flashContext)
    
    @stage.add(@flashLayer)
    @stage.add(@layer)
    
    @x = 10
    @y = 10
    @scale = 15
    @scaleOffset = 1
    @scaleFactor = 1.01
    @lastX = 0
    @lastY = 0
    @letters = '0123456789ABCDEF'.split('')
    @canvas.addEventListener 'mousemove', (evt) =>
      @lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft)  
      @lastY = evt.offsetY || (evt.pageY - canvas.offsetTop)
  
  moveX : (val) =>  
    @context.translate((val/@scaleOffset)*0.5, 0);
    @flashContext.translate((val/@scaleOffset)*0.5, 0);
    @clear(@context)
    @clear(@flashContext)
    
  moveY : (val) =>  
    @context.translate(0, (val/@scaleOffset)*0.5);
    @flashContext.translate(0, (val/@scaleOffset)*0.5);
    @clear(@context)
    @clear(@flashContext)
  
  zoom : (val, center) =>
    if(center)
      pt = @context.transformedPoint(500,225)
    else
      pt = @context.transformedPoint(@lastX,@lastY)
    
    @context.translate(pt.x,pt.y)
    @flashContext.translate(pt.x,pt.y)
    @scaleOffset = Math.pow(@scaleFactor,val)
    @context.scale(@scaleOffset,@scaleOffset)
    @flashContext.scale(@scaleOffset,@scaleOffset)
    @context.translate(-pt.x,-pt.y)
    @flashContext.translate(-pt.x,-pt.y)
    @clear(@context)
    @clear(@flashContext)
    @drawCrosshair(pt.x,pt.y)
  
  clear: (ctx) =>
    ctx.save() 
    ctx.setTransform(1,0,0,1,0,0) 
    ctx.clearRect(0,0,@canvas.width,@canvas.height) 
    ctx.restore()
    #@layer.draw()
  
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
    #console.log params
    if(!@context.drawingPath)
      @context.beginPath()  
      @context.drawingPath = true
    #define aperture
    if(params.type == "circle")
      width = params.outerDiam * @scale *2
      @aperture = 
        flash : (x,y) =>
          xt = @transformX(x)
          yt = @transformY(y)
          @drawCircle(@flashContext,(xt), (yt),width*2)
  
  createContext: (width,height) =>
    tmpCanvas = document.createElement('canvas')
    tmpCanvas.width = width
    tmpCanvas.height = height
    tmpCanvas.getContext('2d')
    
  drawCircle: (ctx,x,y,d) =>
    ctx.beginPath()
    ctx.fillStyle = "#F00"
    #ctx.strokeStyle = "#F00"
    #ctx.scale(0.1,0.1)
    ctx.arc(x, y, d, 0, Math.PI*2, false)
    #ctx.fillRect(x, y, d, d);
    #ctx.lineWidth = 1
    ctx.fill()
    #ctx.stroke()
    ctx.closePath()
      
  randomColor: () ->
      color = '#'
      for i in [1..6]
          color += @letters[Math.round(Math.random() * 15)]
      return color

  select: (params) =>
    #console.log "select"
    
  moveTo: (params) =>
    x = @transformX params.x
    y = @transformY params.y
    @context.moveTo(x, y)
    if(!@firstmove)
      @firstmove = {x:x,y:y}
  
  transformX: (x) =>
    (x*@scale)+@x
    
  transformY: (y) =>
    @canvas.height - ((y * @scale) + @y)
    
  drawTo: (params) =>
    #console.log params
    x = @transformX params.x
    y = @transformY params.y
    @context.lineTo x, y
    
  flash: (params) =>
    #console.log params
    @aperture.flash params.x, params.y
        
  end: (params) =>
    if(@context.drawingPath)
      @context.lineWidth = 1
      @context.strokeStyle = "#00F"
      @context.fillStyle = "#0F0"
      if(@firstmove)
        console.log "goto first"
        @moveTo(@firstmove) 
      @context.stroke()
      #@context.closePath()
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