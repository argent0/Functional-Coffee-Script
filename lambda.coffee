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

fold = (f) ->	#works on iterators
	return (x0) ->
		return (iterator) ->
			r = x0
			while (v = iterator())?
				r = f(r,v)
			return r

iter_stream = (stream) ->
	return () ->
		return drop(stream) if stream
		return undefined

limit = (n,stream) ->
	it = iter_stream(stream)
	return () ->
		return it() if ( not n? or (n-- > 0 ) )
		return undefined

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
	l = limit(n,stream)
	while (v = l())?
		say v

#EXAMPLE: Calculate e(euler's constant)

factorial = (n) ->
	return 1 if n == 0
	return n*factorial(n-1)

op_sum = (x,y) -> x+y
op_inc = (x) -> op_sum(x,1)
op_identity = (x) -> x
ups = iterate_function(op_inc)
s = ups(0)
op_series_term = (x) -> 1/factorial(x)
t = transform op_series_term, s
sum = fold(op_sum)(0)
i = limit(30,t)
say sum(i)
