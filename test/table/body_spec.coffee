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

  context 'with a custom row component class', ->

    it 'should use that component to render the row', ->
      CustomRow = React.createClass
        render: ->
          row = @props.row

          cells = for col in @props.columns
            value = row[col.field]
            <td key=col.field className='custom-row'>{value}</td>

          <tr>{cells}</tr>

      columns = [
        {field: 'name'},
        {field: 'age'},
      ]
      rows = [{name: 'Billy', age: 66, id: 1}]
      body = <Body keyField='id' columns=columns rows=rows rowClass=CustomRow />
      view = @render <table>{body}</table>

      expect(@allByClass(view, 'custom-row')).not.to.be.empty

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

  context 'with selected rows', ->

    beforeEach ->
      excited  = (name) -> "#{name}!!"
      columns  = [
        {field: 'name', label: 'Name', format: excited},
        {field: 'age'},
      ]

      rows  = [
        {name: 'Billy', age: 66, id: 1}
        {name: 'Tommy', age: 53, id: 2}
        {name: 'Bobby', age: 32, id: 3}
      ]

      selectedRows = [1, 3]

      body = <Body  keyField     = 'id'
                    columns      = columns
                    rows         = rows
                    selectedRows = selectedRows />

      @view = @render <table>{body}</table>
      @el   = @view.getDOMNode()

    it 'should add a "selected" class to all selected rows', ->
      bodyEl = @el.children[0]
      firstRowEl = bodyEl.children[0]
      secondRowEl = bodyEl.children[1]
      thirdRowEl = bodyEl.children[2]

      expect(firstRowEl).to.haveClass 'selected'
      expect(secondRowEl).not.to.haveClass 'selected'
      expect(thirdRowEl).to.haveClass 'selected'
