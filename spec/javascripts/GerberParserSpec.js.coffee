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

  it "should parse image polarity line", () ->
    parser = new GerberParser()
    expect(parser.parse(["%IPPOS*%"]))
    .toEqual([{command:'imagePolarity', polarity:'positive'}])
    
  it "should parse layer polarity line", () ->
    parser = new GerberParser()
    expect(parser.parse(["%LPD*%"]))
    .toEqual([{command:'layerPolarity', polarity:'dark'}])
  
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
      rotation : 22.5
    ])
  
  it "should parse all lines", () ->
    parser = new GerberParser()
    console.log parser.parse('G75*
    G70*
    %OFA0B0*%
    %FSLAX24Y24*%
    %IPPOS*%
    %LPD*%
    %AMOC8*
    5,1,8,0,0,1.08239X$1,22.5*
    %
    %ADD10C,0.0060*%
    D10*
    X008738Y018900D02*
    X009838Y018900D01*
    X009855Y018902D01*
    X009872Y018906D01*
    X009888Y018913D01*
    X009902Y018923D01*
    X009915Y018936D01*
    X009925Y018950D01*
    X009932Y018966D01*
    X009936Y018983D01*
    X009938Y019000D01*
    X009938Y019600D01*
    X009936Y019617D01*
    X009932Y019634D01*
    X009925Y019650D01*
    X009915Y019664D01*
    X009902Y019677D01*
    X009888Y019687D01*
    X009872Y019694D01*
    X009855Y019698D01*
    X009838Y019700D01*
    X008738Y019700D01*
    X008721Y019698D01*
    X008704Y019694D01*
    X008688Y019687D01*
    X008674Y019677D01*
    X008661Y019664D01*
    X008651Y019650D01*
    X008644Y019634D01*
    X008640Y019617D01*
    X008638Y019600D01*
    X008638Y019000D01*
    X008640Y018983D01*
    X008644Y018966D01*
    X008651Y018950D01*
    X008661Y018936D01*
    X008674Y018923D01*
    X008688Y018913D01*
    X008704Y018906D01*
    X008721Y018902D01*
    X008738Y018900D01*
    X012938Y021850D02*
    X012938Y022950D01*
    X012940Y022967D01*
    X012944Y022984D01*
    X012951Y023000D01*
    X012961Y023014D01*
    X012974Y023027D01*
    X012988Y023037D01*
    X013004Y023044D01*
    X013021Y023048D01*
    X013038Y023050D01*
    X013638Y023050D01*
    X013655Y023048D01*
    X013672Y023044D01*
    X013688Y023037D01*
    X013702Y023027D01*
    X013715Y023014D01*
    X013725Y023000D01*
    X013732Y022984D01*
    X013736Y022967D01*
    X013738Y022950D01*
    X013738Y021850D01*
    X013736Y021833D01*
    X013732Y021816D01*
    X013725Y021800D01*
    X013715Y021786D01*
    X013702Y021773D01*
    X013688Y021763D01*
    X013672Y021756D01*
    X013655Y021752D01*
    X013638Y021750D01*
    X013038Y021750D01*
    X013021Y021752D01*
    X013004Y021756D01*
    X012988Y021763D01*
    X012974Y021773D01*
    X012961Y021786D01*
    X012951Y021800D01*
    X012944Y021816D01*
    X012940Y021833D01*
    X012938Y021850D01*
    M02*'.split(/\s+/m))
    
)
    
    
#{command:'format',edge:match[1],coordinate:match[2],xInt:match[3],xDec:match[4],yInt:match[5],yDec:match[6]}