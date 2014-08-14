# cmpnt
Basic low-level React.js UI Components.

## Usage

```coffeescript

React  = require 'react'
Button = require 'cmpnt/form/button'

Clicker = React.createClass
  onClick: ->
    alert 'Cool!'

  render: ->
    <Button onClick=@onClick>Cool?</Button>
```

## Publishing
The npm-published source lives in build. The root of this project is
non-publishable.
