# @name: FilePicker
#
# @description: Renders a button that, when clicked, opens a file upload
# dialog. Passes the result files into the `onChange` function.
#
# @example: ->
#   React.createClass
#     onChange: (files) ->
#       alert "Got file: #{files[0].name}"
#
#     render: ->
#       <FilePicker onChange=@onChange>Upload File</FilePicker>
React = require 'react'

Button = require './button'


FilePicker = React.createClass
  displayName: 'FilePicker'

  propTypes:
    onChange:   React.PropTypes.func
    className:  React.PropTypes.string
    btnType:    React.PropTypes.string

  getDefaultProps: ->
    btnType: 'default'

  onClick: ->
    @refs.fileInput.getDOMNode().click()

  onChange: (e) ->
    e?.preventDefault()
    @props.onChange?(e.currentTarget.files)
    # Chrome doesn't trigger an onChange event for uploading the same file.
    # We clear out the value of the DOM node in between uploads to trick it.
    @refs.fileInput.getDOMNode().value = ''

  render: ->
    <div>
      <Button type=@props.btnType className=@props.className onClick=@onClick>
        {@props.children}
      </Button>
      <input type="file" ref="fileInput" style={display: 'none'}
        onChange=@onChange />
    </div>


module.exports = FilePicker
