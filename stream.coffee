###
#	Streams
###

@stream = {}

iEmpty = @iterator.iEmpty
Iterator = @iterator.Iterator

newNode = (head,tail) ->
	[head,tail]

sHead = (node) ->
	node[0]

is_promise = (arg) ->
	typeof (arg) == "function"

sTail = (node) ->
	if is_promise( node[1] )
		node[1] = node[1]()
	return node[1]

say = (msg) ->
	console.log msg

sTransform = (f, stream) ->
	#applies a function to a stream
	return unless stream?
	promise = () ->
		return sTransform(f,sTail(stream))
	nn = newNode(f(sHead(stream)), -> promise() )

iFunction = (f) ->
	# returns a function that takes an initial value
	# and subsecuent aplications of f to that value
	return (x0) ->
		s = undefined
		promise = () ->
			sTransform(f,s)
		s = newNode(x0,-> promise() )
		return s

iStream = (stream) ->
	return new Iterator ->
		return sDrop(stream) if stream
		return iEmpty

sTake = (n,stream) ->
	it = iStream(stream)
	@iterator.iTake(n,it)

sDrop = (node) ->
	h = sHead(node)
	t = sTail(node)
	if t?
		node[0] = t[0]
		node[1] = t[1]
	else
		node = undefined
	return h

sShow = (n,stream) -> #dumps a stream to the console
	l = sTake(n,stream)
	while (v = l())?
		say v

@stream.iFunction = iFunction
@stream.sTransform = sTransform
@stream.iStream = iStream

# END of Streams
