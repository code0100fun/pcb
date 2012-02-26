class GerberParser
  constructor: () ->
    @patterns =
      'parseD' : /X([0-9]*)Y([0-9]*)D([0-9]*)\*/
      'parseFS' : /%FS(L|T|D)(A|I)X([0-7])([0-7])Y([0-7])([0-7])\*%/
      'parseADD' : /%ADD([1-9]{1}[0-9]{1}[0-9]?)(C|R|O|P),([0-9]*.[0-9]*)(X([0-9]*.[0-9]*))*\*%/
      'parseSelect': /D([1-9]{1}[0-9]{1}[0-9]?)\*/
      'parseEnd': /M02\*/
      'parseMacro': /^%AM.*%$/
    @commands = 
      2 : 'moveTo'
      1 : 'drawTo'
    @shapes = 
      'C' : 'circle'
      'R' : 'rectangle'
      'O' : 'oval'
      'P' : 'polygon'
    @shapeParams =
      'C' : ['outerDiam', 'innerDiam', 'innerHeight']
      'R' : ['outerWidth', 'outerHeight', 'innerWidth', 'innerHeight']
      'O' : ['outerWidth', 'outerHeight', 'innerWidth', 'innerHeight']
      'P' : ['outerDiam', 'sides', 'rotation', 'innerWidth', 'innerHeight']
    @primatives = 
      1 : 'circle'
      2 : 'vector'
      20 : 'line'
      21 : 'rectangleC'
      22 : 'rectangleBL'
      4 : 'outline'
      5 : 'polygon' 
      6 : 'moire'
      7 : 'thermal' 
    @primParams =
      1 :  ['exposure', 'diameter', 'x', 'y']
      2 :  ['exposure', 'width', 'x1', 'y1', 'x2', 'y2', 'rotation']
      20 : ['exposure', 'width', 'x1', 'y1', 'x2', 'y2', 'rotation']
      21 : ['exposure', 'width', 'height', 'x', 'y', 'rotation']
      22 : ['exposure', 'width', 'height', 'x', 'y', 'rotation']
      4 :  ['exposure', 'sides', 'xN', 'yN', 'rotation']
      5 :  ['exposure', 'sides', 'x', 'y', 'diameter', 'rotation']
      6 :  ['x', 'y', 'diameter', 'thickness', 'gap', 'maxRings', 'crossWidth', 'crossLength','rotation']
      7 :  ['x', 'y', 'outerDiam', 'innerDiam', 'gapThickness', 'rotation']
  parse: (lines) =>
    parsed = []
    lineToParse = ''
    _.each lines, (line) =>
      if (line.match(/%.*/) || lineToParse != '') && !(line.match /%.*%/)
        lineToParse += line
      if lineToParse == '' || lineToParse.match /^%.*%$/
        lineToParse = line if lineToParse == ''
        parsed.push @matchCommand lineToParse
        lineToParse = ''
    return parsed
  
  matchCommand: (line) =>
    for command,pattern of @patterns
      if (@patterns.hasOwnProperty(command))
        match = line.match(@patterns[command])
        return @[command](line,match) if match != null
    return null
  
  parseD: (line, match) => # D command
    # X008738Y018900D02*
    # X009838Y018900D01*
    match = match || line.match(@patterns.parseD)
    return null if match == null
    return (
      command: @commands[parseInt(match[3])],
      x: parseFloat(match[1])/1000, 
      y: parseFloat(match[2])/1000 
    )
    
  parseFS: (line, match) => # Format specification
    # %FSLAX24Y24*%
    match = match || line.match(@patterns.parseFS)
    return null if match == null
    return (
      command:'formatSpec'
      edge:match[1]
      coordinate:match[2]
      xInt:parseInt(match[3])
      xDec:parseInt(match[4])
      yInt:parseInt(match[5])
      yDec:parseInt(match[6])
    )
    
  parseADD: (line, match) => # Aperture definition
    # %ADD10C,0.0060*%
    match = match || line.match(@patterns.parseADD)
    return null if match == null
    command = (
      command:'apertureDef'
      code:parseInt(match[1])
      type:@shapes[match[2]]
    )  
    command[@shapeParams[match[2]][0]] = match[3] && parseFloat(match[3])
    command[@shapeParams[match[2]][1]] = match[5] && parseFloat(match[5])
    command[@shapeParams[match[2]][2]] = match[7] && parseFloat(match[7])
    command[@shapeParams[match[2]][3]] = match[9] && parseFloat(match[9])
    return command
  
  parseSelect: (line, match) => # Aperture select
    # D10*
    match = match || line.match(@patterns.parseSelect)
    return null if match == null
    return (
      command:'select'
      code:parseInt(match[1])
    )
    
  parseEnd: (line, match) => # End of program
    # M02*
    match = match || line.match(@patterns.parseEnd)
    return null if match == null
    return (
      command:'end'
    )
  
  parseMacro: (line, match) => # Aperture macro
    # %AMOC8*
    # 5,1,8,0,0,1.08239X$1,22.5*
    # %
    match = match || line.match(@patterns.parseMacro)
    return null if match == null
    return (
      command:'macro'
    )       
    
window.GerberParser = GerberParser