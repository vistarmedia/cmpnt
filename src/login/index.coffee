# @name: Login
#
# @description: Renders an email/password login box with an option title and
# errors.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       pending: false
#       error:   undefined
#
#     handleChange: (email, password) ->
#       complete = =>
#         error = if password isnt 'tiger' then "Password isn't tiger"
#         @setState(pending: false, error: error)
#
#       @setState(pending: true)
#       setTimeout(complete, 500)
#
#     render: ->
#       <Login title    = 'Login Time'
#              email    = 'foo@bar.com'
#              error    = @state.error
#              onSubmit = @handleChange
#              disabled = @state.pending />
React  = require 'react'


Login = React.createClass
  displayName: 'Login'

  propTypes:
    title:    React.PropTypes.string
    disabled: React.PropTypes.bool
    email:    React.PropTypes.string
    password: React.PropTypes.string
    onSubmit: React.PropTypes.func
    error:    React.PropTypes.string

  getDefaultProps: ->
    disabled: false

  handleSubmit: (e) ->
    e.preventDefault()
    email    = @refs.email.getDOMNode().value.trim()
    password = @refs.password.getDOMNode().value.trim()
    @props.onSubmit?(email, password)

  render: ->
    <span className='login'>
      {@_title()}
      {@_error()}
      {@_body()}
    </span>

  _title: ->
    if @props.title?
      <div className='panel-heading'>
        <h3 className='panel-title'>{@props.title}</h3>
      </div>
    else
      null

  _error: ->
    return null unless @props.error
    <div className='alert alert-warning' role='alert'>
      {@props.error}
    </div>

  _body: ->
    <div className='panel-body'>
      <form role='form' onSubmit=@handleSubmit>
        <fieldset>

          <div className='form-group'>
            <input className    = 'form-control'
                   placeholder  = 'E-mail'
                   name         = 'email'
                   type         = 'email'
                   ref          = 'email'
                   disabled     = @props.disabled
                   defaultValue = @props.email />
          </div>

          <div className='form-group'>
            <input className    = 'form-control'
                   placeholder  = 'Password'
                   name         = 'password'
                   type         = 'password'
                   ref          = 'password'
                   disabled     = @props.disabled
                   defaultValue = @props.password />
          </div>

          <input type      = 'submit'
                 value     = 'Login'
                 disabled  = @props.disabled
                 className = 'btn btn-lg btn-success btn-block' />
        </fieldset>
      </form>
    </div>


module.exports = Login
