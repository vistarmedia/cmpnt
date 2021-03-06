# @name: SourceSink
#
# @description: Source-sink view. Takes a set of options and (selected) values
# and populates a source sink view. Selected values (ones in the sink) will be
# passed to the onChange function when modified.
#
# The display value is calculated by passing each model to the "format"
# property.
#
# NOTE: Option ids must be strings, otherwise they will be coerced into
# strings during selection and the view won't function correctly.
#
# @example: ->
#   React.createClass
#     render: ->
#       options = [{
#         name: 'Option 1'
#         id: '1'
#       }, {
#         name: 'Option 2'
#         id: '2'
#       }, {
#         name: 'Option 3'
#         id: '3'
#       }, {
#         name: 'Value 1'
#         id: '4'
#       }]
#
#       value = ['3']
#
#       format = (m) -> m.name
#
#       <SourceSink
#         options=options
#         value=value
#         format=format />
_       = require 'lodash'
React   = require 'react'

Button  = require '../form/button'
Types   = require '../types'


OptionList = React.createClass
  displayName: 'SourceSink.OptionList'

  propTypes:
    format:   React.PropTypes.func.isRequired
    onSelect: React.PropTypes.func.isRequired
    options:  Types.idNameList.isRequired
    selected: Types.idNameList.isRequired

  selectChanged: (e) ->
    opts = e.currentTarget.querySelectorAll('option')
    selectedIds = (opt.getAttribute('value') for opt in opts \
                   when opt.selected is true)
    selectedOptions = (o for o in @props.options when o.id in selectedIds)

    @props.onSelect(selectedOptions)

  render: ->
    selectedIds = (o.id for o in @props.selected)

    options = for model in @props.options
      <option key=model.id value=model.id>
        {@props.format(model)}
      </option>

    <select className='form-control'
      onChange=@selectChanged
      value=selectedIds
      multiple>
      {options}
    </select>


FilteredOptionList = React.createClass
  displayName: 'SourceSink.FilteredOptionList'

  propTypes:
    options: Types.idNameList.isRequired

  getInitialState: ->
    filter: ''

  filterChanged: (e) ->
    @setState
      filter: e.currentTarget.value

  render: ->
    filtered = (opt for opt in @props.options when \
      opt.name.toLowerCase().indexOf(@state.filter) isnt -1)

    optionListProps = _.defaults({
      options: filtered
    }, @props)

    <div className='filter-container'>
      <input className='form-control'
        type='text'
        onChange=@filterChanged
        placeholder='Filter'
        value=@state.filter />
      {React.createElement(OptionList, optionListProps)}
    </div>


SourceSink = React.createClass
  displayName: 'SourceSink'

  propTypes:
    format:   React.PropTypes.func
    options:  Types.idNameList
    onChange: React.PropTypes.func
    value:    React.PropTypes.array

  getDefaultProps: ->
    format:   (o) -> o.name
    onChange: ->
    options:  []
    value:    []

  getInitialState: ->
    @stateFromProps(@props)

  componentWillReceiveProps: (props) ->
    @setState(@stateFromProps(props))

  stateFromProps: (props) ->
    # Lodash set operations do a === comparison, and we don't want to force
    # users of this component to use the same option instances. Go through
    # the given options and decide which side based on an id comparison.
    sourceOptions = []
    sinkOptions = []
    _.forEach props.options, (o) ->
      container = if o.id in props.value then sinkOptions else sourceOptions
      container.push(o)

    sourceOptions:  sourceOptions
    sourceSelected: []
    sinkSelected:   []
    sinkOptions:    sinkOptions

  sourceChanged: (options) ->
    @setState
      sourceSelected: options

  sinkChanged: (options) ->
    @setState
      sinkSelected: options

  moveToSink: ->
    toMove = @state.sourceSelected

    @setState({
      sourceOptions:  _.difference(@state.sourceOptions, toMove)
      sinkOptions:    _.union(@state.sinkOptions, toMove)
      sourceSelected: []
    }, -> @props.onChange(@_ids(@state.sinkOptions)))

  moveToSource: ->
    toMove = @state.sinkSelected

    @setState({
      sourceOptions: _.union(@state.sourceOptions, toMove)
      sinkOptions:   _.difference(@state.sinkOptions, toMove)
      sinkSelected:  []
    }, -> @props.onChange(@_ids(@state.sinkOptions)))

  clearSink: ->
    @setState({
      sourceOptions:  @props.options
      sinkOptions:    []
      sourceSelected: []
      sinkSelected:   []
    }, -> @props.onChange(@_ids(@state.sinkOptions)))

  render: ->
    <div className='source-sink'>
      <form>
        <div className='source-container'>
          <FilteredOptionList
            options=@state.sourceOptions
            selected=@state.sourceSelected
            onSelect=@sourceChanged
            format=@props.format />
        </div>

        <div className='move'>
          <Button className='tosink' onClick=@moveToSink
            disabled={@state.sourceSelected.length is 0}>&rarr;</Button>
          <Button className='tosource' onClick=@moveToSource
            disabled={@state.sinkSelected.length is 0}>&larr;</Button>
        </div>

        <div className='sink-container'>
          <OptionList
            options=@state.sinkOptions
            selected=@state.sinkSelected
            onSelect=@sinkChanged
            format=@props.format />

          <a className='clearall' onClick=@clearSink>Clear all</a>
        </div>

      </form>
    </div>

  _ids: (options) ->
    options.map (o) -> o.id


SourceSink.OptionList = OptionList
SourceSink.FilteredOptionList = FilteredOptionList

module.exports = SourceSink
