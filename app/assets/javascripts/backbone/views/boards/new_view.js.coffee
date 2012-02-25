Pcb.Views.Boards ||= {}

class Pcb.Views.Boards.NewView extends Backbone.View
  template: JST["backbone/templates/boards/new"]

  events:
    "submit #new-board": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (board) =>
        @model = board
        window.location.hash = "/#{@model.id}"

      error: (board, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
