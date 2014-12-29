require '../test_case'

React     = require 'react'
sinon     = require 'sinon'
{expect}  = require 'chai'

Login = require '../../src/login'


describe 'Login', ->

  it 'should should a title if given', ->
    login = @render <Login title='Bonjour!' />
    expect(login).to.haveElement '.panel-heading'

  it 'should have no title if not given', ->
    login = @render <Login />
    expect(login).to.not.haveElement '.panel-heading'

  context 'when pre-populated', ->

    beforeEach ->
      @login = @render <Login email='frank@test.com' password='secretz' />
      @el    = @login.getDOMNode()

    it 'should set the values of the fields', ->
      email    = @el.querySelector 'input[name=email]'
      password = @el.querySelector 'input[name=password]'

      expect(email.value).to.equal 'frank@test.com'
      expect(password.value).to.equal 'secretz'

  context 'when disabled', ->

    beforeEach ->
      @login = @render <Login disabled=true />

    it 'should disable email/password', ->
      expect(@login).to.haveElement 'input[name=email][disabled]'
      expect(@login).to.haveElement 'input[name=password][disabled]'

    it 'should disable the submit button', ->
      expect(@login).to.haveElement 'input[type=submit][disabled]'


  context 'when submitting the form', ->

    beforeEach ->
      @onSubmit = sinon.spy()
      @login    = @render <Login onSubmit = @onSubmit
                                 email    = 'scott@oracle.com'
                                 password = 'tiger' />

      form = @login.getDOMNode().querySelector 'form'
      @simulate.submit(form)

    it 'should invoke the onSubmit handler with the email and password', ->
      expect(@onSubmit).to.have.been.calledWith('scott@oracle.com', 'tiger')

  context 'when given an error', ->

    beforeEach ->
      @login = @render <Login error='Password not cool enough' />

    it 'should display the error above the email', ->
      expect(@login).to.haveElement '.alert.alert-warning'
