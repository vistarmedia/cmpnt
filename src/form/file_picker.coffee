React       = require 'react'

Button = require './button'


FilePicker = React.createClass
  displayName: 'FilePicker'

  propTypes:
    onChange:   React.PropTypes.func
    className:  React.PropTypes.string

  onClick: ->
    @refs.fileInput.getDOMNode().click()

  onChange: (e) ->
    e?.preventDefault()
    @props.onChange?(e.currentTarget.files)

  render: ->
    <div>
      <Button className=@props.className onClick=@onClick>
        {@props.children}
      </Button>
      <input type="file" ref="fileInput" style={display: 'none'}
        onChange=@onChange />
    </div>


module.exports = FilePicker
