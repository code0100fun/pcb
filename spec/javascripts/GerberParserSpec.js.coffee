describe("Gerber Parser", () ->
  
  it "should convert gerber lines to collection of command lines", () ->
    parser = new GerberParser()
    expect(parser.parse([
      "X008738Y018900D02*"
      "X009838Y018900D01*"
      "%FSLAX24Y24*%"
      "%ADD10C,0.0060*%"
    ]))
    .toEqual([
      {command:'moveTo',x:8.738,y:18.9}
      {command:'drawTo',x:9.838,y:18.9}
      {command:'formatSpec',edge:'L',coordinate:'A',xInt:2,xDec:4,yInt:2,yDec:4}
      {command:'apertureDef',code:10,type:'circle',outerDiam:0.0060}
    ])
  
  it "should parse D command line", () ->
    parser = new GerberParser()
    expect(parser.parse(["X008738Y018900D02*"]))
    .toEqual([{command: 'moveTo',x:8.738,y:18.9}])
  
  it "should identify command for line", () ->
    parser = new GerberParser()
    expect(parser.matchCommand("X008738Y018900D02*"))
    .toEqual({command: 'moveTo',x:8.738,y:18.9})
  
  it "should parse format specification line", () ->
    parser = new GerberParser()
    expect(parser.parse(["%FSLAX24Y24*%"]))
    .toEqual([{command:'formatSpec',edge:'L',coordinate:'A',xInt:2,xDec:4,yInt:2,yDec:4}])
  
  it "should parse aperture definition line", () ->
    parser = new GerberParser()
    expect(parser.parse(["%ADD10C,0.0060*%"]))
    .toEqual([{command:'apertureDef',code:10,type:'circle',outerDiam:0.0060}])

  it "should parse select aperture line", () ->
    parser = new GerberParser()
    expect(parser.parse(["D10*"]))
    .toEqual([{command:'select',code:10}])
  
  it "should parse end of program line", () ->
    parser = new GerberParser()
    expect(parser.parse(["M02*"]))
    .toEqual([{command:'end'}])
  
  it "should parse macro lines", () ->
    parser = new GerberParser()
    expect(parser.parse([
      '%AMOC8*'
      '5,1,8,0,0,1.08239X$1,22.5*'
      '%'
    ]))
    .toEqual([
      command:'macro'
      name: 'OC8'
      primative:'polygon'
      exposure:true
      sides:8
      x:0
      y:0
      diameter:1.08239
    ])
    
)
    
    
#{command:'format',edge:match[1],coordinate:match[2],xInt:match[3],xDec:match[4],yInt:match[5],yDec:match[6]}