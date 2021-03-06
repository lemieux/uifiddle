UI =
  Components: {}
  Resources:
    CSS:
      bootstrap: '/stylesheets/bootstrap.css'

UI.registerComponent = (data)->
  data = _.clone data
  data.fields = new UI.Fieldset(data.fields, parse: true)
  component = UI.Component.extend(data)
  component.prototype.fields.each (field)-> field.component = data.name
  UI.Components[data.name] = component

UI.Component = Backbone.Model.extend
  initialize: ->
    @view = new UI.ComponentView(model: this)
  stylesheets: (overrides = {})->
    _.map @css, (style)->
      overrides[style] || UI.Resources.CSS[style] || style
  source: -> @view.source()
  render: -> @view.render().el
  toJSON: ->
    _.extend @fields.defaults(), @attributes

UI.ComponentView = Backbone.View.extend
  initialize: ->
    @template = Handlebars.compile(@model.template)
  source: -> @template(@model.toJSON())
  render: ->
    newEl = $(@source())
    @$el.replaceWith(newEl) if @el

    @setElement(newEl)
    this

UI.Field = Backbone.Model.extend
  initialize: ->
    @view = new UI.FieldView(model: @)
  toJSON: ->
    _.extend @attributes,
      component: @component.replace(/\//g,'-')

UI.FieldView = Backbone.View.extend
  render: (value)->
    @$el.html Helpers.field(@model.toJSON(), value || @model.get('default'))
    this

UI.Fieldset = Backbone.Collection.extend
  model: UI.Field
  defaults: ->
    out = {}
    @each (field)->
      out[field.get('name')] = field.get('default')
    out

window.UI = UI

Handlebars.registerHelper "split", (string, separator, options)->
  array = string.split(separator)
  options.fn(array, options)

Handlebars.registerHelper "last", (collection, options)->
  comp = this
  comp = this.toString() if _.isString(this)
  if _.last(collection) == comp
    options.fn(this)
  else
    options.inverse(this)