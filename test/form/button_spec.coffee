require '../test_case'

{expect} = require 'chai'

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

  it 'should invoke its onClick handler', (done) ->
    onClick = -> done()
    button  = @render <Button onClick=onClick />
    @simulate.click(button.getDOMNode())

  it 'should pass through className', ->
    el = @render(<Button className='pants' />).getDOMNode()
    expect(el).to.haveClass 'pants'

  it 'should not start or end with a space', ->
    cls = @render(<Button />).getDOMNode().className

    expect(cls[0]).to.not.equal ' '
    expect(cls[cls.length-1]).to.not.equal ' '
