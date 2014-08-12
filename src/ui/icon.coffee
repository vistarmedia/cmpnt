# @name: Icon
#
# @description:  Icon component using "Font Awesome" under the hood. See FA's
# documentation for acceptable values http://fortawesome.github.io/Font-Awesome
#
# @example: ->
#   React.createClass
#     render: ->
#       <span>
#         <Icon name='desktop' />
#         <Icon name='search' size='large' />
#       </span>
React = require 'react'


Icon = React.createClass

  propTypes:
    name:       React.PropTypes.string
    className:  React.PropTypes.string
    status:     React.PropTypes.oneOf ['success']
    size:       React.PropTypes.oneOf ['large']
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

    <i className={classes.join(' ')} />


module.exports = Icon
