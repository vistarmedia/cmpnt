# @name: Download Link
#
# @description: A simple link used for download Blobs as files
#
# @example: ->
#   React.createClass
#     render: ->
#       csv = [
#         'one,two,three\n',
#         'four,five,six\n'
#       ]
#       blob = new Blob(csv, type: 'text/csv')
#       <DownloadLink fileName='test.csv' blob=blob>Download</DownloadLink>
#
React = require 'react'


DownloadLink = React.createClass

  propTypes:
    blob:     React.PropTypes.object.isRequired
    fileName: React.PropTypes.string.isRequired

  componentWillMount: ->
    @uri = URL.createObjectURL(@props.blob)

  componentWillUnmount: ->
    if @uri?
      URL.removeObjectURL(@uri)

  render: ->
    <a href=@uri download=@props.fileName>{@props.children}</a>


module.exports = DownloadLink
