class GerberParser
  constructor: () ->
    
  parse: (lines) ->
    #X008738Y018900D02*
    #X009838Y018900D01*
    parsed = []
    _.each lines, (line) ->
      match = line.match(/X([0-9]*)Y([0-9]*)D([0-9]*)\*/)
      parsed.push { x: parseFloat(match[1])/1000, y: parseFloat(match[2])/1000 }
    return parsed
    
window.GerberParser = GerberParser