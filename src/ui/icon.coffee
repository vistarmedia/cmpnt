# @name: Icon
#
# @description:  Icon component using "Font Awesome" under the hood. See FA's
# documentation for acceptable values http://fortawesome.github.io/Font-Awesome
#
# @example: ->
#   React.createClass
#
#     render: ->
#       <span>
#         <p><Icon /> Empty icon</p>
#         <p><Icon name='bomb' /> Bomb</p>
#         <p><Icon name='bomb' status='success' /> Successful bomb(?)</p>
#         <p><Icon name='bomb' size='large'/> Large Bomb</p>
#       </span>
React = require 'react'


Icon = React.createClass
  displayName: 'Icon'

  propTypes:
    name:       React.PropTypes.string
    className:  React.PropTypes.string
    status:     React.PropTypes.oneOf ['success', 'danger', 'muted']
    size:       React.PropTypes.oneOf ['large', '5x']
    align:      React.PropTypes.oneOf ['center']

  render: ->
    classes = ['icon']
    if @props.className? then classes.push(@props.className)

    unless @props.name?
      classes.push('spacer')
      return <span className={classes.join(' ')} />

    classes.push("fa fa-#{@props.name}")

    if @props.status? then classes.push("text-#{@props.status}")

    switch @props.align
      when 'center' then classes.push('fa-fw')

    switch @props.size
      when 'large' then classes.push('fa-lg')
      when '5x'    then classes.push('fa-5x')

    <i className={classes.join(' ')} />


module.exports = Icon
