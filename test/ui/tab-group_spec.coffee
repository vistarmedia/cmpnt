require '../test_case'

React     = require 'react'
{expect}  = require 'chai'

TabGroup = require '../../src/ui/tab-group'


describe 'Tab', ->
  beforeEach ->
    @coolTabCls =
      <TabGroup.Tab label="My cool Tab">
        <h1>Cool tab, bro</h1>
      </TabGroup.Tab>

  it 'should pass its children as content', ->
    el = @render(@coolTabCls).getDOMNode()
    children = el.childNodes
    expect(children).to.have.length 1

    expect(children[0]).to.have.tagName 'H1'
    expect(children[0]).to.have.innerHTML 'Cool tab, bro'

describe 'Tab Group Header', ->

  it 'should be a list', ->
    header = @render(<TabGroup.Header active='one' labels={['one', 'two']} />)
    el     = header.getDOMNode()
    expect(el).to.have.tagName 'UL'

    children = el.childNodes
    expect(children).to.have.length 2

    one = children[0]
    expect(one).to.have.tagName 'LI'
    expect(one.childNodes[0]).to.have.innerHTML 'one'

  it 'should have the active tab marked', ->
    header = @render(<TabGroup.Header active='two' labels={['one', 'two']} />)
    children = header.getDOMNode().childNodes

    expect(children[0]).to.not.haveClass 'active'
    expect(children[1]).to.haveClass 'active'

  it 'should invoke a change handler when mounted', (done) ->
    onChange = (label) ->
      expect(label).to.equal 'fish'
      done()

    headerCls = <TabGroup.Header onChange=onChange active='fish' labels={['dogs', 'fish']} />
    @render(headerCls)

  it 'should activate a new tab when clicked', ->
    invocations = 0
    onChange = (label) ->
      switch invocations
        when 0 then expect(label).to.equal 'one'
        when 1 then expect(label).to.equal 'two'
        else fail('should not have happened')
      invocations += 1

    header = @render(<TabGroup.Header active='one' onChange=onChange
                                      labels={['one', 'two', 'three']} />)
    # click 'two'
    twoItem = header.getDOMNode().childNodes[1]
    twoLink = twoItem.childNodes[0]
    @simulate.click(twoLink)

describe 'Tab Group', ->

  beforeEach ->
    @tabGroupCls =
      <TabGroup>
        <TabGroup.Tab label='One'>First</TabGroup.Tab>
        <TabGroup.Tab label='Two'>Second</TabGroup.Tab>
        <TabGroup.Tab label='Three'>Third</TabGroup.Tab>
      </TabGroup>

  it 'should allow the active tab to be over-ridden', ->
    tabGroup = @render(
      <TabGroup active='Two'>
        <TabGroup.Tab label='One'>First</TabGroup.Tab>
        <TabGroup.Tab label='Two'>Second</TabGroup.Tab>
        <TabGroup.Tab label='Three'>Third</TabGroup.Tab>
      </TabGroup>)
    expect(tabGroup.state.active).to.equal 'Two'

  it 'should render inactive tabs when onlyRenderActive is not specified', ->
    tabGroup = @render(
      <TabGroup>
        <TabGroup.Tab label='One'>First</TabGroup.Tab>
        <TabGroup.Tab label='Two'>Second</TabGroup.Tab>
        <TabGroup.Tab label='Three'>Third</TabGroup.Tab>
      </TabGroup>)
    el = tabGroup.getDOMNode()

    tabs = el.querySelectorAll('.tab-pane')
    expect(tabs).to.have.length 3

  it 'should render inactive tabs when onlyRenderActive is false', ->
    tabGroup = @render(
      <TabGroup onlyRenderActive=false>
        <TabGroup.Tab label='One'>First</TabGroup.Tab>
        <TabGroup.Tab label='Two'>Second</TabGroup.Tab>
        <TabGroup.Tab label='Three'>Third</TabGroup.Tab>
      </TabGroup>)
    el = tabGroup.getDOMNode()

    tabs = el.querySelectorAll('.tab-pane')
    expect(tabs).to.have.length 3

  it 'should only render active tab when onlyRenderActive is true', ->
    tabGroup = @render(
      <TabGroup onlyRenderActive=true>
        <TabGroup.Tab label='One'><span className='1'>First</span></TabGroup.Tab>
        <TabGroup.Tab label='Two'><span className='2'>Second</span></TabGroup.Tab>
        <TabGroup.Tab label='Three'><span className='3'>Third</span></TabGroup.Tab>
      </TabGroup>)
    el = tabGroup.getDOMNode()

    tabs = el.querySelectorAll('.tab-pane')
    expect(tabs).to.have.length 1
    expect(el.querySelector('span.1')).to.exist
    expect(el.querySelector('span.2')).to.not.exist
    expect(el.querySelector('span.3')).to.not.exist

  it 'should have hidden tabs on the DOM', ->
    tabGroup = @render(
      <TabGroup active='One'>
        <TabGroup.Tab label='One'><span className='1'>First</span></TabGroup.Tab>
        <TabGroup.Tab label='Two'><span className='2'>Second</span></TabGroup.Tab>
      </TabGroup>)

    el = tabGroup.getDOMNode()

    tabs = el.querySelectorAll('.tab-pane')
    expect(tabs).to.have.length 2

    expect(tabs[0]).to.haveClass 'active'
    expect(tabs[1]).to.not.haveClass 'active'

    expect(el.querySelector('span.1')).to.exist
    expect(el.querySelector('span.2')).to.exist

