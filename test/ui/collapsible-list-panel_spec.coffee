require '../test_case'

{expect} = require 'chai'

CollapsibleListPanel  = require '../../src/ui/collapsible-list-panel'
RangeSelector         = require '../../src/ui/range-selector'


describe 'Collapsible List Panel', ->

  beforeEach ->
    @view = @render(
      <CollapsibleListPanel title="The List">
        <CollapsibleListPanel.Item label="Some Bull">
          <RangeSelector options={[{value: 0, label: 'Zero'}]} />
        </CollapsibleListPanel.Item>
        <CollapsibleListPanel.Item label="More Baloney">
          <RangeSelector options={[{value: 'A', label: 'Letter A'}]} />
        </CollapsibleListPanel.Item>
      </CollapsibleListPanel>)

  it 'should contain title', ->
    expect(@view.getDOMNode().innerHTML).to.contain 'The List'

  it 'should contain selector labels', ->
    html = @view.getDOMNode().innerHTML
    expect(html).to.contain 'Some Bull'
    expect(html).to.contain 'More Baloney'

  it 'should expand a selector when toggle is clicked', ->
    items   = @allByType(@view, CollapsibleListPanel.Item)
    toggles = @allByType(@view, CollapsibleListPanel.Toggle)

    expect(items[0].getDOMNode()).to.haveClass 'collapsed'
    expect(items[1].getDOMNode()).to.haveClass 'collapsed'
    @simulate.click toggles[0].getDOMNode()
    expect(items[0].getDOMNode()).not.to.haveClass 'collapsed'
    expect(items[1].getDOMNode()).to.haveClass 'collapsed'

    expect(items[0].getDOMNode()).not.to.haveClass 'collapsed'
    expect(items[1].getDOMNode()).to.haveClass 'collapsed'
    @simulate.click toggles[1].getDOMNode()
    expect(items[0].getDOMNode()).not.to.haveClass 'collapsed'
    expect(items[1].getDOMNode()).not.to.haveClass 'collapsed'
