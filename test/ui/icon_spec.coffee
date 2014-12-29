require '../test_case'

React     = require 'react'
{expect}  = require 'chai'

Icon = require '../../src/ui/icon'


describe 'Icon', ->

  describe 'when not given a name', ->
    it 'should not have an fa class', ->
      icon = @render(<Icon />).getDOMNode()
      expect(icon).to.haveClass 'icon'
      expect(icon).to.not.haveClass 'fa'

  describe 'when given a name', ->
    it 'should have an fa class and icon', ->
      icon = @render(<Icon name="fax" />).getDOMNode()
      expect(icon).to.haveClass 'icon'
      expect(icon).to.haveClass 'fa'
      expect(icon).to.haveClass 'fa-fax'

  it 'should drop in a spacer when no name is given', ->
    icon = @render(<Icon />).getDOMNode()
    expect(icon.tagName).to.equal 'SPAN'
    expect(icon.className).to.include 'icon'
    expect(icon.className).to.include 'spacer'

  it 'should pass-through className', ->
    icon = @render(<Icon className='my-class' />).getDOMNode()
    expect(icon.className).to.include 'my-class'
