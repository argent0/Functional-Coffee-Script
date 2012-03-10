newNode = (args) ->
	[head,tail] = args

head = (args) ->
	args[0][0]

is_promise = (args) ->
	typeof (args[0]) == "function"

tail = (node) ->
	if is_promise( [node[1]] )
		node[1] = node[1]()
	return node[1]

uptoS = (args) ->
	[from,to] = args
	return if from>to
	promise = () ->
		uptoS([from+1,to])
	newNode([from, promise])

drop = (node) ->
	h = head([node])
	t = tail(node)
	# node = t #won't work
	if t?
		node[0] = t[0]
		node[1] = t[1]
	else
		node = undefined
	return h

showStream = (args) ->
	[n,node] = args
	while node and ( not n? or n-- > 0 )
		say drop(node)


empty = []	#the empty iterator

say = (msg) ->
	console.log msg

range = (args) ->
	[from,step,to] = args

	value = from-step
	return ->
		return value=value+step if value < to
		return empty

curry_n = (args) ->
	#Makes a function with N arguments take default values
	[n,f] = args
	c = (sargs) ->
		final = (ssargs) ->
			f(sargs.concat(ssargs))
		return final if sargs.length >= n
		final = (ssargs) ->
			f(sargs.concat(ssargs))
		return curry_n( [n-sargs.length,final])

transform = (args) -> #applies a function to a stream
	[f,s] = args
	return unless s?
	promise = () ->
		t = tail(s)
		transform([f,tail(s)])
	nn = newNode([f(head([s])), promise])

op_inc = (x) -> x*x

showFirst9 = curry_n([2,showStream])([9])
s = uptoS([0,1000])
t = transform([op_inc,s])
showFirst9([t])()
