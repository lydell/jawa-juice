###
# Copyright 2013-2014 Simon Lydell
# X11 (“MIT”) Licensed. (See LICENSE.)
###

render = require("../index")

equal = (expected, fragment)->
  container = document.createElement("div")
  container.appendChild(fragment)
  actual = container.innerHTML
  return if expected == actual
  console.dir {expected, actual}
  throw new Error "Expected `#{expected}` to equal `#{actual}`"

suite "render", ->

  suite "elements", ->

    test "create", ->
      equal '<p></p>', render ->
        @p

      equal '<br>', render ->
        @br

      equal '<p></p><br><p></p>', render ->
        @p
        @br
        @p


    test "underscores to hyphens", ->
      equal '<x-foo-bar></x-foo-bar>', render ->
        @x_foo_bar


  suite "attributes", ->

    test "add classes", ->
      equal '<p class="class"></p>', render ->
        @p.class

      equal '<p class="a b c"></p>', render ->
        @p.a.b.c


    test "underscores to hyphens", ->
      equal '<p class="a-b-c"></p>', render ->
        @p.a_b_c


    test "add attributes", ->
      equal '<p attribute="value"></p>', render ->
        @p(attribute: "value")

      equal '<p attribute="value"></p>', render ->
        @p attribute: "value"

      equal '<p obj="[object Object]" arr="a,1" num="1" str="a"></p>', render ->
        @p(str: "a", num: 1, arr: ["a", 1], obj: {})

      equal '<p obj="[object Object]" arr="a,1" num="1" str="a"></p>', render ->
        @p str: "a", num: 1, arr: ["a", 1], obj: {}


    test "boolean attributes", ->
      equal '<p boolean="boolean"></p>', render ->
        @p(boolean: true)

      equal '<p></p>', render ->
        @p(boolean: false)


    test "data attributes", ->
      equal '<p data-string="&quot;a&quot;"></p>', render ->
        @p(data: {string: "a"})

      equal '<p data-number="1"></p>', render ->
        @p(data: {number: 1})

      equal '<p data-null="null"></p>', render ->
        @p(data: {null: null})

      equal '<p data-true="true"></p>', render ->
        @p(data: {true: true})

      equal '<p data-false="false"></p>', render ->
        @p(data: {false: false})

      equal '<p data-array="[&quot;a&quot;,1]"></p>', render ->
        @p(data: {array: ["a", 1]})

      equal '<p data-obj="{&quot;key&quot;:&quot;value&quot;}"></p>', render ->
        @p(data: {obj: {key: "value"}})

      equal '<p data-c="3" data-b="2" data-a="1"></p>', render ->
        @p(data: {a: 1, b: 2, c: 3})


    test "no duplication", ->
      equal '<p a="1"></p>', render ->
        @p(a: 1)(a: 1)


    suite "class", ->

      test "whitespace", ->
        equal '<p class="a b c"></p>', render ->
          @p(class: "  a   b    c ")


      test "array", ->
        equal '<p class="a b c"></p>', render ->
          @p(class: ["a", "b", "c"])


      test "concatenation", ->
        equal '<p class="a b c d e f g"></p>', render ->
          @p.a.b(class: "c d")(class: ["e", "f"]).g


      test "no duplication", ->
        equal '<p class="a b"></p>', render ->
          @p.a.a(class: "a b")(class: ["b", "b"]).b


      test "not underscores to hyphens", ->
        equal '<p class="a_b_c"></p>', render ->
          @p(class: "a_b_c")

        equal '<p class="block__element--modifier"></p>', render ->
          @p(class: "block__element--modifier")


    test "dynamic attributes", ->
      attributes = {a: 1}
      equal '<p a="1"></p>', render ->
        @p(attributes)


    test "mix classes and attributes", ->
      equal '<p e="4" d="3" c="1" class="a b c d"></p>', render ->
        @p.a.b(c: 1, d: 2, class: "b c").d(d: 3)(e: 4)


  suite "content", ->

    test "text", ->
      equal '<p>text</p>', render ->
        @p "text"

      equal '<p>1</p>', render ->
        @p 1

      equal '<p>text,1</p>', render ->
        @p ["text", 1]


    test "block", ->
      equal '<p><em>foo</em><strong>bar</strong></p>', render ->
        @p ->
          @em "foo"
          @strong "bar"


    test "element", ->
      equal '<pre><code>foo(bar);</code></pre>', render ->
        @pre @code """
          foo(bar);
          """


    test "text with inline elements", ->
      equal '<p>text <a>link</a> te<em><strong>xt</strong></em></p>', render ->
        @p "text ", (@a "link"), " te", (@em @strong "xt")


    test "escaping", ->
      userInput = "</p>"
      equal '<p>&lt;/p&gt; &amp;gt; &lt;/p&gt;</p>', render ->
        @p "</p> &gt; #{userInput}"


  test "both attributes and content", ->
    equal '<p class="class">text</p>', render ->
      @p.class "text"

    equal '<p attribute="value">text</p>', render ->
      @p(attribute: "value") "text"

    equal '<p attribute="value">text</p>', render ->
      @p attribute: "value", "text"


  test "plain text", ->
    equal 'text', render ->
      @ "text"


  test "locals", ->
    locals =
      foo: "bar"
    template = (locals)->
      @p locals.foo
    equal '<p>bar</p>', render template, locals


  test "includes", ->
    locals =
      foo: "bar"
    template = (locals)->
      @ require "test/include"
    equal '<p>Include with bar</p>', render template, locals


  suite "mixins", ->

    test "inline", ->
      equal '<p id="foo">foo bar</p><p>end</p>', render ->
        mixin = (attributes, arg, block)=>
          @p(attributes) "foo #{arg}"
          @ block
        mixin id: "foo", "bar", ->
          @p "end"


    test "`require`d (explicit `.call`)", ->
      equal '<div><p>Mixined foo</p></div>', render ->
        mixin = require("test/mixin")
        @div ->
          mixin.call @, "foo"


    test "`require`d (`@`-assigned)", ->
      equal '<div><p>Mixined foo</p></div>', render ->
        @mixin = require("test/mixin")
        @div ->
          @mixin "foo"


  suite "custom document", ->

    class Document
      constructor: -> @calls = 0
      createDocumentFragment: -> {appendChild: => @calls++}
      createElement: -> @calls++
      assertCalls: (calls)->
        unless @calls == calls
          throw new Error "Expected `render` to take a custom `document`."


    test "simple", ->
      doc = new Document
      render doc, ->
        @p
      doc.assertCalls(2)


    test "bind", ->
      doc = new Document
      localRender = render.bind(undefined, doc)
      localRender ->
        @p
      doc.assertCalls(2)


    test "locals", ->
      locals =
        foo: "bar"
      template = (locals)->
        @p locals.foo
      equal '<p>bar</p>', render document, template, locals
