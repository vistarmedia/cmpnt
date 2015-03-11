# @name: Pill
#
# @description:  A word inside a little pill.  Will hide itself when 'x' is
# clicked.
#
# @example: ->
#   React.createClass
#
#     onClose: (value) ->
#       alert("closing component with value: #{value}")
#
#     render: ->
#       <div>
#         <Pill value="very good">Dogs</Pill>
#         <Pill value="very tasty" onClose={@onClose}>Food</Pill>
#         <Pill value="very healthy" onClose={@onClose}>
#           Medicine
#         </Pill>
#       </div>


React      = require 'react'
{classSet} = require('react/addons').addons


Pill = React.createClass
  displayName: 'Pill'

  propTypes:
    className: React.PropTypes.string
    onClose:   React.PropTypes.func
    value:     React.PropTypes.string
    visible:   React.PropTypes.bool

  getDefaultProps: ->
    className:  'pill'
    visible:    true

  getInitialState: ->
    visible: @props.visible

  onClose: (e) ->
    @props.onClose?(@props.value)
    @setState(visible: false)

  _classes: ->
    classes =
      hidden:           not @state.visible
      label:            true
      "label-default":  true

    classes[@props.className] = @props.className?
    classSet(classes)

  render: ->
    close = <a className='close' onClick={@onClose}>✕</a>

    <span className={@_classes()}>
      {@props.children}
      {close if @props.onClose}
    </span>


module.exports = Pill
