class RenderAdapter
  constructor: () ->
    
class KineticJSAdapter extends RenderAdapter
  constructor: (elem) ->
    console.log('KineticJSAdapter ctor')
    @stage = new Kinetic.Stage(elem, 1000, 450)
    @layer = new Kinetic.Layer()
    #@layer = @stage.backstageLayer
    @canvas = @layer.canvas
    @context = @canvas.getContext('2d')
    @trackTransforms(@context)
    #svg = document.createElementNS("http://www.w3.org/2000/svg",'svg')
    #xform = svg.createSVGMatrix()
    #pt  = svg.createSVGPoint()
    
    #@context.getTransform = () ->
    #  xform
    
    #@context.transformedPoint = (x,y) ->
    #  pt.x=x; pt.y=y;
    #	 pt.matrixTransform(xform.inverse())
    
    @stage.add(@layer)
    
    @x = 10
    @y = 10
    @scale = 15
    @scaleOffset = 1
    @scaleFactor = 1.01
    @lastX = 0
    @lastY = 0
    #@layer.setPosition(@x,@y)
    #@stage.setScale(@scale)
    @canvas.addEventListener 'mousemove', (evt) =>
      @lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft)  
      @lastY = evt.offsetY || (evt.pageY - canvas.offsetTop)
      #console.log "mousemove x #{@lastX} y #{@lastY}"
  
  init: () =>
    @context.beginPath() 
    
  moveX : (val) =>  
    #@x += val
    @context.translate((val/@scaleOffset)*0.5, 0);
    @clear()
    
  moveY : (val) =>  
    #@y += val
    #@layer.setPosition(@x, @y);
    @context.translate(0, (val/@scaleOffset)*0.5);
    @clear()
  
  zoom : (val, center) =>
    if(center)
      pt = @context.transformedPoint(500,225)
    else
      pt = @context.transformedPoint(@lastX,@lastY)
    
    @context.translate(pt.x,pt.y)
    @scaleOffset = Math.pow(@scaleFactor,val)
    @context.scale(@scaleOffset,@scaleOffset)
    @context.translate(-pt.x,-pt.y)
    @clear()
    @drawCrosshair(pt.x,pt.y)
  
  clear: () =>
    @context.save() 
    @context.setTransform(1,0,0,1,0,0) 
    @context.clearRect(0,0,@canvas.width,@canvas.height) 
    @context.restore()
  
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
    #console.log "apertureDef"
  select: (params) =>
    #console.log "select"
    
  moveTo: (params) =>
    x = (params.x*@scale)+@x
    y = @canvas.height - ((params.y * @scale) + @y)
    @context.moveTo(x, y)
    
  drawTo: (params) =>
    x = (params.x*@scale)+@x
    y = @canvas.height - ((params.y * @scale) + @y)
    @context.lineTo(x, y)
    
  end: (params) =>
    @context.lineWidth = 1
    @context.strokeStyle = "#00F"
    @context.stroke()
    @context.closePath()
    
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