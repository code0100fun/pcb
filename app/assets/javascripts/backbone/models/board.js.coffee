class Pcb.Models.Board extends Backbone.Model
  paramRoot: 'board'

  defaults:
    name: null

class Pcb.Collections.BoardsCollection extends Backbone.Collection
  model: Pcb.Models.Board
  url: '/boards'
