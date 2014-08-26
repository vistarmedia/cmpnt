require '../test_case'
sinon = require 'sinon'

React     = require 'react'
Backbone  = require 'backbone'
{expect}  = require 'chai'

DataTable = require '../../src/table/data-table'


class Model extends Backbone.Model


describe 'Data Table', ->

  beforeEach ->
    @models = for i in [0..499]
      new Model(id: i, name: "Model #{i+1}")

    @columns = [
      {field: 'id',   label: 'ID'},
      {field: 'name', label: 'Name'},
    ]

    @_filterImpl = (models, term) -> models
    @filter = (models, term) => @_filterImpl(models, term)

    @table = @render DataTable
      columns:  @columns,
      models:   @models,
      filter:   @filter

    @input = @table.getDOMNode().getElementsByTagName('input')[0]

  it 'should render formatted column headers', ->
    el = @render(<DataTable columns=@columns />).getDOMNode()
    headers = el.querySelectorAll('thead > tr > th')
    expect(headers).to.have.length 2

    expect(headers[0]).to.have.textContent 'ID'
    expect(headers[1]).to.have.textContent 'Name'

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

  it 'should initially have undefined filter', ->
    expect(@table.state.filter).to.be.undefined

  it 'should change the filter when the input is changed', ->
    @input.value = 'guuuuurl'
    @simulate.keyUp(@input)
    expect(@table.state.filter).to.equal 'guuuuurl'

  it 'should not invoke a callback when there has been no change', ->
    @input.value = 'my cool filter'
    render = sinon.spy(@table, 'render')

    @simulate.keyUp(@input)
    @simulate.keyUp(@input)
    expect(render.calledOnce).to.be.true

    @table.render.restore()

  it 'should not render items per page select if no perPage prop', ->
    el     = @table.getDOMNode()
    select = el.querySelector('select')
    expect(select).not.to.exist

  # TODO
  #it 'should move to page 0 on filter change'

  # TODO
  #it 'should let the collection decide how to filter'

  context 'using items per page select', ->

    beforeEach ->
      @table = @render DataTable
        columns:       @columns
        filter:        @filter
        models:        @models
        itemsPerPage:  10
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
