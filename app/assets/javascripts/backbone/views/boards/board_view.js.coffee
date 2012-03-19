Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.BoardView extends Backbone.View
  template: JST["backbone/templates/boards/board"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).css({height:'100%'})
    $(@el).html(@template(@model.toJSON() ))
    return this
