Overview
========

jawa-juice is a small, [CoffeeKup]-like DOM-based templating language. Just for fun.

I made it primarily to learn about [`Proxy`], which is the secret sauce to the whole thing. Since
the browser support for `Proxy` is quite bad, it's not very usable. I've only tested it in Firefox.
And since it is DOM based, you can't use it on Node.js either. Well, you could try to use some DOM
module and patch `document`, or whatever. I just tried to create a nice DSL with small amounts of
code.

Here is CoffeeKup's example translated to jawa-juice, just to give a little taste what it looks
like.

```coffee
module.exports = ({title, description, path, user, post})->
  @html ->
    @head ->
      @meta(charset: "UTF-8")
      @title "#{title or "Untitled"} | A completely plausible website"
      @meta(name: 'description', content: description) if description?

      @link(rel: "stylesheet", href: "/css/app.css")

      @style """
        body {font-family: sans-serif}
        header, nav, section, footer {display: block}
      """

      @script(src: "/js/jquery.js")

    @body ->
      @header ->
        @h1 title or 'Untitled'

        @nav ->
          @ul ->
            @li @a(href: "/") "Home" unless path is "/"
            @li @a(href: "/chunky") "Bacon!"
            @li switch user.role
              when "owner", "admin"
                @a(href: "/admin") "Secret Stuff"
              when 'vip'
                @a(href: "/vip") "Exclusive Stuff"
              else
                @a(href: "/commoners") "Just Stuff"

      @div::myid.myclass.anotherclass(style: "position: fixed") ->
        @p "Divitis kills! Inline styling too."

      @section ->
        breadcrumb = require("mixins/breadcrumb")
        breadcrumb.call @, separator: ">", clickable: yes

        @h2 "Let's count to 10:"
        @p i for i in [1..10]

        form_to = (attributes, post, block)=>
          @form(attributes)(method: "post") block
        # another way ...
        form_to = (attributes, post, block)=>
          @form(attributes)(method: "post") ->
            @label
              @ "Date:"
              @input(type: "date")
            @ block

        form_to id: "to-form", post, ->
          @textbox::title(label: "Title:")
          @textbox::author(label: "Author:")
          @input(type: "submit") "Save"

      @footer ->
        @p "Bye!"
```

But remember that jawa-juice is DOM-based, so you probably won't generate a whole document like this
with it. More likely just a little partial here and there.

[CoffeeKup]: https://github.com/mauricemach/coffeekup
[`Proxy`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy


Installation
============

`component install lydell/jawa-juice`


Usage
=====

```coffee
render = require "jawa-juice"
template = require "templates/tatooine"

fragment = render template,
  user: "R2-D2"
  location: "Luke's Speeder"

document.body.appendChild(fragment)
```


Development
===========

Tests
-----

[brunch] is used for testing. You need either `brunch` (`npm install -g brunch`), or
`./node_modules/.bin` in your path.

First run `npm install` to install dependencies.

Then run `npm test` to compile test files and fire up a server. Finally visit localhost:3333 in a
browser.

The cool thing is that the tests will auto-reload as soon as you modify either the source code or
the tests.

[brunch]: http://brunch.io

x-package.json5
---------------

package.json and component.json are both generated from x-package.json5 by
using [`xpkg`]. Only edit x-package.json5, and remember to run `xpkg` before
committing!

[`xpkg`]: https://github.com/kof/node-xpkg

Language reference
==================

First, have a look at the example above. That should get you going.

Then, have a look at the [tests](test/index.coffee). They're straight-forward and self-documenting.


License
=======

[The X11 “MIT” License](LICENSE).
