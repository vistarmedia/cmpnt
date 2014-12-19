# @name: Types
#
# @description:  A collection of custom prop types.


React      = require 'react'


idName = React.PropTypes.shape
  id:   React.PropTypes.any
  name: React.PropTypes.string

idContent = React.PropTypes.shape
  id:      React.PropTypes.any
  # With react 0.12, renderable will be renamed to "node"
  content: React.PropTypes.renderable


module.exports =
  idName:        idName
  idNameList:    React.PropTypes.arrayOf(idName.isRequired)
  idContent:     idContent
  idContentList: React.PropTypes.arrayOf(idContent.isRequired)
