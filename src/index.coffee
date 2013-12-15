###
This file is part of jawa-juice.

jawa-juice is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

jawa-juice is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with jawa-juice.  If not,
see <http://www.gnu.org/licenses/>.
###

# Note: I've tried to keep it really simple, and tiny. Therefore, the syntax is really permissive.
# Silly things like `@foo::("content").id` is not prohibited, but discouraged, for example.

class Renderer
	constructor: (@locals)->

	identifier: {}

	render: (fn, parent)->
		context = new Proxy @updateParent.bind(this, parent), get: (target, tag)=>
			element = @createElement(tag)
			parent.node.appendChild(element.node)
			element.proxy
		fn.call(context, @locals)

	createElement: (tag)->
		setId = no
		element =
			node: document.createElement(@underscoresToHyphens(tag))
			identifier: @identifier
		element.proxy = new Proxy @updateParent.bind(this, element), get: (target, prop)=>
			prop = @underscoresToHyphens(prop)
			switch
				when prop is ""
					return element
				when setId
					element.node.id = prop
					setId = no
				when prop is "prototype"
					setId = yes
				else
					element.node.classList.add(prop)
			element.proxy

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
				parent.node.appendChild(document.createTextNode(arg))

		parent.proxy

	setAttributes: (element, attributes)->
		for own attribute, value of attributes
			switch attribute
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


module.exports = (fn, locals)->
	fragment = document.createDocumentFragment()
	new Renderer(locals).render(fn, {node: fragment})
	fragment
