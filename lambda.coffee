iEmpty = [] #indicates that an iterator is empty
class Iterator
	@empty: false
	constructor: (@callback)->

	next: ->
		if not @empty
			v = @callback()
			if not ( v == iEmpty )
				return v
			@empty = true

iTake = (n,iterator,defaultValue=undefined) ->
	# Takes n values from an itertator
	return new Iterator ->
		v = iterator.next()
		return v if ( not n? or (n-- > 0 ) ) and not iterator.empty
		return defaultValue if ( not n? or ( n >= 0) ) and defaultValue?
		return iEmpty

iZip = (a,b) ->
	return new Iterator ->
		va = a.next()
		vb = b.next()
		if a.empty or b.empty
			return iEmpty
		return [va,vb]

iMap = (f,iterator) ->
	return new Iterator ->
		v = iterator.next()
		return iEmpty if iterator.empty
		return f(v)

iGrep = (iterator, condition) ->
	return new Iterator ->
		nv = iterator.next()
		while not condition(nv) and not iterator.empty
			nv = iterator.next()
		return nv if not iterator.empty
		return iEmpty

showIterator = (iterator) ->
	# Dumps iterator to stdout
	v = iterator.next()
	until iterator.empty
		say v
		v = iterator.next()

fold = (f) ->	#works on iterators
	return (x0) ->
		return (iterator) ->
			r = x0
			v = iterator.next()
			while not iterator.empty
				r = f(r,v)
				v = iterator.next()
			return r

iConcat = (a,b) ->
	if b.length > 0
		nextIterator = b.shift()
	else
		nextIterator = undefined
	if nextIterator? and b.length > 0
		n = iConcat(nextIterator, b)
	else
		n = nextIterator
	return new Iterator ->
		va = a.next()
		return va if not a.empty
		vn = n.next()
		return vn if not n.empty
		return iEmpty

# Array-Iterator functions
iterList = (array) ->
	l = array.length
	i = 0
	return new Iterator ->
		return iEmpty if i>=l
		array[i++]

cycle = (array,trigger=undefined) ->
	#cycles an array indefinitely
	# optional trigger to call when a cycle is done
	l = array.length
	i = 0
	return new Iterator ->
		if i >= l
			i=0
			trigger() if trigger?
		return array[i++]

coCycle = (array,n,trigger=undefined) ->
	#Same as cycle but n times. Returns an array
	return undefined if ( not n? or ( n <=0 ) )
	if n == 1
		return cycle(array,trigger)

	l = array.length
	i = 0
	
	reset = ->
		i++

	subCycle = coCycle(array,n-1,reset)
	
	return new Iterator ->
		s = subCycle.next()
		if i >= l
			i=0
			trigger() if trigger?
		return [array[i]].concat(s) if i < l

###
#	Streams
###

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

iter_stream = (stream) ->
	return new Iterator ->
		return drop(stream) if stream
		return iEmpty

sTake = (n,stream) ->
	it = iter_stream(stream)
	iTake(n,it)

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
	l = sTake(n,stream)
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
i = sTake(30,t)
say sum(i)
