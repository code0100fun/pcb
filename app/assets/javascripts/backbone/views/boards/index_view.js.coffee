Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.IndexView extends Backbone.View
  template: JST["backbone/templates/boards/index"]

  initialize: () ->
    @options.boards.bind('reset', @addAll)

  addAll: () =>
    @options.boards.each(@addOne)

  addOne: (board) =>
    view = new Pcb.Views.Boards.BoardView({model : board})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(boards: @options.boards.toJSON() ))
    @addAll()

    return this
