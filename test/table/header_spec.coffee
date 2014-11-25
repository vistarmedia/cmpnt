require '../test_case'

React    = require 'react'
sinon    = require 'sinon'
{expect} = require 'chai'

{Header} = require '../../src/table'


describe 'Table Header', ->

  it 'should be a thead tag', ->
    view = @render <table><Header columns=[] /></table>
    children = view.getDOMNode().childNodes
    expect(children).to.have.length 1
    expect(children[0]).to.have.tagName 'THEAD'

  context 'with no columns', ->

    beforeEach ->
      @view = @render <table><Header columns=[] /></table>

    it 'should show no columns', ->
      expect(@view).to.not.haveElement 'th'

  context 'with one column', ->

    beforeEach ->
      columns = [{field: 'name', label: 'Name'}]
      @view   = @render <table><Header columns=columns /></table>

    it 'should show the column label', ->
      heads = @view.getDOMNode().querySelectorAll 'th'
      expect(heads).to.have.length 1
      expect(heads[0]).to.have.textContent 'Name'

  context 'a column without a label', ->

    beforeEach ->
      columns = [{field: 'name'}]
      @view   = @render <table><Header columns=columns /></table>

    it 'should render the field', ->
      heads = @view.getDOMNode().querySelectorAll 'th'
      expect(heads[0]).to.have.textContent 'name'

  context 'when clicking a header', ->

    beforeEach ->
      columns  = [{field: 'name', unrelated: 666}]
      @onClick = sinon.spy()

      header = <Header columns=columns onClick=@onClick />
      @view  = @render <table>{header}</table>

      head = @view.getDOMNode().querySelector('th')
      @simulate.click(head)

    it 'should invoke a handler with the column def', ->
      expect(@onClick).to.have.been.calledWith
        field:    'name'
        unrelated: 666

  context 'with comparable columns', ->

    beforeEach ->
      columns  = [
        {field: 'id', comparator: null}
        {field: 'name', unrelated: 666}
      ]

      @onClick = sinon.spy()
      header   = <Header columns=columns onClick=@onClick />
      @view    = @render <table>{header}</table>

    it 'should not be sortable with a null comparator', ->
      idHead = @view.getDOMNode().querySelector 'th:contains(id)'
      expect(idHead).to.have.className ''

    it 'should not fire a click event for a null comparator', ->
      id = @view.getDOMNode().querySelector 'th:contains(id)'
      @simulate.click(id)
      expect(@onClick).to.not.have.been.called

    it 'should not be sortable with an undefined comparator', ->
      nameHead = @view.getDOMNode().querySelector 'th:contains(name)'
      expect(nameHead).to.have.className 'sortable'
