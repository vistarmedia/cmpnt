require '../test_case'

React     = require 'react'
sinon     = require 'sinon'
{expect}  = require 'chai'

Button = require '../../src/form/button'


describe 'Button', ->
  it 'should not be disabled by default', ->
    button = @render <Button />
    el     = button.getDOMNode()
    expect(el).to.not.haveClass 'disabled'

  it 'can be disabled', ->
    button = @render <Button disabled=on />
    el     = button.getDOMNode()
    expect(el).to.haveClass 'disabled'

  it 'should invoke its onClick handler', ->
    onClick = sinon.spy()
    button  = @render <Button onClick=onClick />
    @simulate.click(button.getDOMNode())

    expect(onClick).to.have.been.called

  it 'should pass through className', ->
    el = @render(<Button className='pants' />).getDOMNode()
    expect(el).to.haveClass 'pants'

  it 'should not start or end with a space', ->
    cls = @render(<Button />).getDOMNode().className

    expect(cls[0]).to.not.equal ' '
    expect(cls[cls.length-1]).to.not.equal ' '

  it 'should set type=submit with submit type', ->
    el = @render(<Button type='submit' />).getDOMNode()

    expect(el.attributes.type.data).to.equal 'submit'

  it 'should set type=button with other types', ->
    el = @render(<Button type='primary' />).getDOMNode()

    expect(el.attributes.type.data).to.equal 'button'
