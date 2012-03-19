class Pcb.Routers.BoardsRouter extends Backbone.Router
  initialize: (options) ->
    @boards = new Pcb.Collections.BoardsCollection()
    @boards.reset options.boards

  routes:
    "/tests"    : "tests"
    "/new"      : "newBoard"
    "/index"    : "index"
    "/:id/edit" : "edit"
    "/:id"      : "show"
    ".*"        : "index"
    
  tests: ->
    @view = new Pcb.Views.Boards.TestsView()
    $("#boards").html(@view.render().el)
  
  newBoard: ->
    @view = new Pcb.Views.Boards.NewView(collection: @boards)
    $("#boards").html(@view.render().el)

  index: ->
    @view = new Pcb.Views.Boards.IndexView(boards: @boards)
    $("#boards").html(@view.render().el)

  show: (id) ->
    board = @boards.get(id)

    @view = new Pcb.Views.Boards.ShowView(model: board)
    $("#boards").css({height:'100%'})
    $("#boards").html(@view.render().el)

  edit: (id) ->
    board = @boards.get(id)

    @view = new Pcb.Views.Boards.EditView(model: board)
    $("#boards").html(@view.render().el)
