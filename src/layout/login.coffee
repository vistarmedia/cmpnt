# @name: LoginLayout
#
# @description: Renders a top-level login-layout of a box floating in the middle
# of the screen. The page is based off of this mockup:
#   http://ironsummitmedia.github.io/startbootstrap-sb-admin-2/login.html
#
# @example: ->
#   React.createClass
#     render: ->
#       <LoginLayout>
#         hey.
#       </LoginLayout>
React = require 'react'


LoginLayout = React.createClass
  displayName: 'LoginLayout'

  render: ->
    <div className='row'>
      <div className='col-md-4 col-md-offset-4'>
        <div className='login-panel panel panel-default'>
          {@props.children}
        </div>
      </div>
    </div>


module.exports = LoginLayout
