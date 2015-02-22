# @name: Types
#
# @description:  A collection of custom prop types.


React  = require 'react'
moment = require 'moment'


idName = React.PropTypes.shape
  id:   React.PropTypes.any
  name: React.PropTypes.string

idContent = React.PropTypes.shape
  id:      React.PropTypes.any
  content: React.PropTypes.node

MomentType = React.PropTypes.instanceOf moment().constructor


module.exports =
  MomentType:        MomentType
  idContent:         idContent
  idContentList:     React.PropTypes.arrayOf(idContent.isRequired)
  idName:            idName
  idNameList:        React.PropTypes.arrayOf(idName.isRequired)
