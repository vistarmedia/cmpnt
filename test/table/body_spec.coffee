require '../test_case'

React    = require 'react'
{expect} = require 'chai'

{Body} = require '../../src/table'


describe 'Table Body', ->

  it 'should be a body tag', ->
    view = @render <table><Body keyField='id' columns=[] rows=[] /></table>
    children = view.getDOMNode().childNodes
    expect(children).to.have.length 1
    expect(children[0]).to.have.tagName 'TBODY'

  context 'with one column and one row', ->

    beforeEach ->
      @columns = [{field: 'name', label: 'Name'}]
      @rows    = [{name: 'Billy', size: 66, id: 1}]

      body  = <Body keyField='id' columns=@columns rows=@rows />
      @view = @render <table>{body}</table>

    it 'should have one row with the defined column', ->
      rows = @view.getDOMNode().querySelectorAll 'tr'
      expect(rows).to.have.length 1
      expect(@view).to.haveElement 'td:contains(Billy)'

  context 'with a formatter', ->

    beforeEach ->
      excited  = (name) -> "#{name}!!"
      columns  = [
        {field: 'name', label: 'Name', format: excited},
        {field: 'age'},
      ]

      rows  = [{name: 'Billy', age: 66, id: 1}]
      body  = <Body keyField='id' columns=columns rows=rows />
      @view = @render <table>{body}</table>
      @el   = @view.getDOMNode()

    it 'should format columns with a formatter', ->
      nameCells = @el.querySelectorAll('td[data-reactid$=".$name"]')
      expect(nameCells).to.have.length 1
      expect(nameCells[0]).to.have.textContent 'Billy!!'

    it 'should not format columns without a formatter', ->
      ageCells = @el.querySelectorAll('td[data-reactid$=".$age"]')
      expect(ageCells).to.have.length 1
      expect(ageCells[0]).to.have.textContent '66'
