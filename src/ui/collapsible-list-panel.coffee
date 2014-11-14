# @name: CollapsibleListPanel
#
# @description: A layout for a group of collapsible items.
#
# @example: ->
#   React.createClass
#     render: ->
#       <CollapsibleListPanel title='Characters'>
#         <CollapsibleListPanel.Item label='Letters' visible=true>
#           <p>A, B, C</p>
#         </CollapsibleListPanel.Item>
#         <CollapsibleListPanel.Item label='Numbers'>
#           <p>1, 2, 3</p>
#         </CollapsibleListPanel.Item>
#       </CollapsibleListPanel>
React       = require 'react'
{classSet}  = require('react/addons').addons

Button = require '../form/button'

Icon = require '../ui/icon'


CollapsibleListPanel = React.createClass
  displayName: 'CollapsibleListPanel'

  propTypes:
    title: React.PropTypes.string

  render: ->
    title = if @props.title
      <div className='panel-heading'>{@props.title}</div>
    else
      null

    <div className='collapsible-list-panel panel panel-default'>
      {title}
      <div className='panel-body'>
        {@props.children}
      </div>
    </div>


Item = React.createClass
  displayName: 'CollapsibleListPanel.Item'

  propTypes:
    children: React.PropTypes.component.isRequired
    label:    React.PropTypes.string.isRequired
    visible:  React.PropTypes.bool

  getDefaultProps: ->
    visible: false

  getInitialState: ->
    visible: @props.visible

  buttonClicked: ->
    @setState visible: not @state.visible

  render: ->
    icon    = if @state.visible then 'minus-square' else 'plus-square'
    classes = classSet
      'collapsible-list-panel-item': true
      'collapsed': not @state.visible

    <div className=classes>
      <CollapsibleListPanel.Toggle
          onClick = @buttonClicked
          on      = @state.visible
          label   = @props.label />
      <div className='item-content'>
        {@props.children}
      </div>
    </div>


Toggle = React.createClass
  displayName: 'CollapsibleListPanel.Toggle'

  propTypes:
    onClick:  React.PropTypes.func
    on:       React.PropTypes.bool
    label:    React.PropTypes.string

  getDefaultProps: ->
    on: false

  render: ->
    icon  = if @props.on then 'minus-square' else 'plus-square'
    <Button className='collapsible-list-button' onClick=@props.onClick>
      <Icon name=icon />
      <label>{@props.label}</label>
    </Button>


CollapsibleListPanel.Item    = Item
CollapsibleListPanel.Toggle  = Toggle

module.exports = CollapsibleListPanel
