describe("Gerber Parser", () ->
  it "should convert gerber lines to collection of lines", () ->
    parser = new GerberParser()
    expect(parser.parse(["X008738Y018900D02*", "X009838Y018900D01*"]))
    .toEqual([{x:8.738,y:18.9},{x:9.838,y:18.9}]))
