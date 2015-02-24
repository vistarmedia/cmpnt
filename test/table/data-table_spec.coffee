require '../test_case'

React     = require 'react'
Backbone  = require 'backbone'
{expect}  = require 'chai'

DataTable = require '../../src/table/data-table'
Pager     = require '../../src/table/paging'


class Model extends Backbone.Model


describe 'Data Table', ->

  beforeEach ->
    @models = for i in [0..499]
      new Model(id: i, name: "Model #{i+1}")

    @columns = [
      {field: 'id',   label: 'ID'},
      {field: 'name', label: 'Name', width: '100%'},
    ]

    @_filterImpl = (models, term) -> models
    @filter = (models, term) => @_filterImpl(models, term)

    @table = @render <DataTable columns = @columns
                                models  = @models
                                filter  = @filter
                                itemsPerPage = 10 />

    @input = @table.getDOMNode().getElementsByTagName('input')[0]

  it 'should render formatted column headers', ->
    el = @render(<DataTable columns=@columns />).getDOMNode()
    headers = el.querySelectorAll('thead > tr > th')
    expect(headers).to.have.length 2

    expect(headers[0].textContent).to.include 'ID'
    expect(headers[1].textContent).to.include 'Name'
    expect(headers[1].style.width).to.equal '100%'
    expect(headers[1].style.maxWidth).to.equal '100%'

  # Right now, this defaults to whatever the page defaults to, which is 10
  it 'should limit the number of rendered rows', ->
    el = @table.getDOMNode()
    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10

  it 'should filter rows', ->
    el = @table.getDOMNode()
    @_filterImpl = (models, term) ->
      m for m in models when m.get('name').indexOf(term) > -1

    filterEl = el.querySelector('input[type="text"]')
    filterEl.value = 'Model 10'
    @simulate.keyUp(filterEl)

    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10
    for row in rows
      [idCol, nameCol] = row.childNodes
      name = nameCol.textContent
      expect(name).to.contain 'Model 10'

  it 'should sort rows', ->
    @table.setSort('id', 1)
    @table.render()

    el = @table.getDOMNode()
    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10
    expect(rows[0].innerHTML).to.contain 'Model 1'

    @table.setSort('id', -1)
    @table.render()

    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10
    expect(rows[0].innerHTML).to.contain 'Model 500'

    @table.setState({ pageStart: 100 })
    @table.render()

    rows = el.querySelectorAll('tbody > tr')
    expect(rows[0].innerHTML).to.contain 'Model 400'

  it 'should not have a default sort field', ->
    expect(@table.state.sort).to.be.null

  it 'should have a default sort order if initialSort is set', ->
    sort =
      field: 'name'
    table = @render <DataTable columns = @columns
                                models  = @models
                                filter  = @filter
                                initialSort = sort
                                itemsPerPage = 10 />
    expect(table.state.sort[0]).to.equal 'name'
    expect(table.state.sort[1]).to.equal -1

  it 'should set the initial sort field', ->
    sort =
      field: 'name'
      dir: 1
    table = @render <DataTable columns = @columns
                                models  = @models
                                filter  = @filter
                                initialSort = sort
                                itemsPerPage = 10 />
    expect(table.state.sort[0]).to.equal 'name'
    expect(table.state.sort[1]).to.equal 1

  it 'should initially have undefined filter', ->
    expect(@table.state.filter).to.be.undefined

  it 'should change the filter when the input is changed', ->
    @input.value = 'guuuuurl'
    @simulate.keyUp(@input)
    expect(@table.state.filterTerm).to.equal 'guuuuurl'

  it 'should not render items per page select if no perPage prop', ->
    table = @render <DataTable columns      = @columns
                               filter       = @filter
                               models       = [] />
    el     = table.getDOMNode()
    select = el.querySelector('select')
    expect(select).not.to.exist

  it 'should update update when the models prop has changed', ->
    el = @table.getDOMNode()
    expect(el.querySelectorAll('tbody > tr')).to.have.length 10

    @table.setProps(models: [new Model(id: 3, name: 'Frank')])
    expect(el.querySelectorAll('tbody > tr')).to.have.length 1

  it 'should page correctly if the number of models grows', ->
    table = @render <DataTable columns      = @columns
                               filter       = @filter
                               itemsPerPage = 10
                               models       = [] />
    el = table.getDOMNode()

    expect(el.querySelectorAll('tbody > tr')).to.have.length 0
    table.setProps(models: @models)
    expect(el.querySelectorAll('tbody > tr')).to.have.length 10

  it 'should use the row class given in the "row" prop', ->
    CustomTestRow = React.createClass
      render: ->
        <tr key={@props.model.id}>
          <td>
            {@props.model.id}
          </td>
          <td>
            custom row for {@props.model.get('name')}
          </td>
        </tr>

    table = @render <DataTable columns = @columns
                               filter = @filter
                               models = @models
                               itemsPerPage = 10
                               row = CustomTestRow />
    tableEl  = table.getDOMNode()
    firstRow = tableEl.querySelector('tr:nth-child(1) > td:nth-child(2)')

    expect(firstRow.innerHTML).to.contain "custom row for"

  # TODO
  it 'should move to page 0 on filter change'

  # TODO
  it 'should move to page 0 on filter change'

  context 'using items per page select', ->

    beforeEach ->
      @table = @render(<DataTable columns = @columns
                                  filter = @filter
                                  models = @models
                                  itemsPerPage = 10 />)
      @tableEl = @table.getDOMNode()
      @rows    = -> @tableEl.querySelectorAll('tbody > tr')

    it 'should render a per page selector', ->
      select = @tableEl.querySelector('select')
      expect(select).to.exist

    it 'should update the number of rows displayed when changed', ->
      select = @tableEl.querySelector('select')

      expect(@rows()).to.have.length 10

      select.value = 5
      @simulate.change(select)

      expect(@rows()).to.have.length 5

    it 'should retain the selected number of rows on paging', ->
      select     = @tableEl.querySelector('select')
      nextButton = @tableEl.querySelector('button[data-reactid$="next"]')

      expect(@rows()).to.have.length 10

      select.value = 5
      @simulate.change(select)
      @simulate.click(nextButton)

      expect(@rows()).to.have.length 5

      @simulate.click(nextButton)

      expect(@rows()).to.have.length 5

    it 'should show the pager if there is greater than one page', ->
      expect(@allByType(@table, Pager)).to.have.length 1
      expect(@allByType(@table, Pager.ItemsPerPageSelect)).to.have.length 1

    it 'should not show the pager if there is only one page', ->
      @table.setProps models: @models[0..4]
      expect(@allByType(@table, Pager)).to.have.length 0
      expect(@allByType(@table, Pager.ItemsPerPageSelect)).to.have.length 0
