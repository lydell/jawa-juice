###
# Copyright 2013-2014 Simon Lydell
# X11 (“MIT”) Licensed. (See LICENSE.)
###

class Renderer
  constructor: (@locals, @document)->

  identifier: {}

  render: (fn, parent)->
    context = new Proxy(@updateParent.bind(this, parent),
      get: (target, tag)=>
        element = @createElement(tag)
        parent.node.appendChild(element.node)
        element.proxy
    )
    fn.call(context, @locals)

  createElement: (tag)->
    element = { node: @document.createElement(@underscoresToHyphens(tag)), @identifier }
    element.proxy = new Proxy(@updateParent.bind(this, element),
      get: (target, prop)=>
        if prop is ""
          return element
        else
          element.node.classList.add(@underscoresToHyphens(prop))
        element.proxy
    )
    element

  updateParent: (parent, args...)->
    for arg in args then switch
      when (element = arg[""])?.identifier is @identifier
        parent.node.appendChild(element.node)
      when Object::toString.call(arg) is "[object Object]"
        @setAttributes(parent, arg)
      when typeof arg is "function"
        @render(arg, parent)
      else
        parent.node.appendChild(@document.createTextNode(arg))

    parent.proxy

  setAttributes: (element, attributes)->
    for own attribute, value of attributes then switch attribute
      when "class"
        if typeof value is "string"
          value = value.trim().split(/\s+/)
        for className in value
          element.node.classList.add(className)
      when "data"
        for own key, dataValue of value
          element.node.dataset[key] = JSON.stringify(dataValue)
      else
        continue if value is false
        value = attribute if value is true
        element.node.setAttribute(attribute, value)
    return

  underscoresToHyphens: (string)-> string.replace(/_/g, "-")


module.exports = (doc, fn, locals)->
  if typeof doc is "function"
    [doc, fn, locals] = [document, doc, fn]
  fragment = doc.createDocumentFragment()
  new Renderer(locals, doc).render(fn, {node: fragment})
  fragment
