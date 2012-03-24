newNode = (head,tail) ->
	[head,tail]

head = (node) ->
	node[0]

is_promise = (arg) ->
	typeof (arg) == "function"

tail = (node) ->
	if is_promise( node[1] )
		node[1] = node[1]()
	return node[1]

uptoS = (args) ->
	[from,to] = args
	return if from>to
	promise = () ->
		uptoS([from+1,to])
	newNode(from, promise)

empty = []	#the empty iterator

say = (msg) ->
	console.log msg

# This may be broken
#curry_n = (args) ->
#	#Makes a function with N arguments take default values
#	[n,f] = args
#	c = (sargs) ->
#		final = (ssargs) ->
#			f(sargs.concat(ssargs))
#		return final if sargs.length >= n
#		final = (ssargs) ->
#			f(sargs.concat(ssargs))
#		return curry_n( [n-sargs.length,final])

transform = (f, stream) -> #applies a function to a stream
	return unless stream?
	promise = () ->
		return transform(f,tail(stream))
	nn = newNode(f(head(stream)), -> promise() )

iterate_function = (f) ->
	return (x0) ->
		s = undefined
		promise = () ->
			transform(f,s)
		s = newNode(x0,-> promise() )
		return s

drop = (node) ->
	h = head(node)
	t = tail(node)
	if t?
		node[0] = t[0]
		node[1] = t[1]
	else
		node = undefined
	return h

showStream = (n,stream) -> #dumps a stream to the console
	while stream and ( not n? or (n-- > 0 ) )
		say drop(stream)

op_inc = (x) -> x+1
u = iterate_function(op_inc)
i = u(1)
limit = (x) ->
	Math.pow (1 + (1/x)), x
identity = (x) -> x
t = transform identity, i
showStream(50,t)
