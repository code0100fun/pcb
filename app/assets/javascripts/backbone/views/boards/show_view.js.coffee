Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.ShowView extends Backbone.View
  template: JST["backbone/templates/boards/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
