newNode = (args) ->
	[head,tail] = args

head = (args) ->
	args[0][0]

is_promise = (args) ->
	typeof (args[0]) == "function"

tail = (node) ->
	#say "Tail #{node}"
	if is_promise( [node[1]] )
		node[1] = node[1]()
	return node[1]

uptoS = (args) ->
	[from,to] = args
	return if from>to
	promise = () ->
		uptoS([from+1,to])
	newNode([from, promise])


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
		#say "Promising a transform s=#{s}"
		#t = [head([s]),s[1]]#tail(s)
		#t = [head([s]),s[1]]#tail(s)
		#say "Transform promise t = #{tail(s)}"
		return transform([f,tail(s)])
		#transform([f,s])
	#say "Transform #{promise}"
	#nn = newNode([f(head([s])), promise ])
	nn = newNode([f(head([s])), -> promise() ] )

iterate_function = (f) ->
	return (x0) ->
		s = undefined
		promise = () ->
			transform([f,s])
		s = newNode([x0,-> promise() ])
		#say "Iter #{s}"
		return s

drop = (node) ->
	h = head([node])
	t = tail(node) #esta es la linea que falla
	# node = t #won't work
	if t?
		node[0] = t[0]
		node[1] = t[1]
	else
		node = undefined
	return h

showStream = (args) -> #dumps a stream to the console
	[n,node] = args
	while node and ( not n? or (n-- > 0 ) )
		say drop(node)

op_inc = (x) -> x+1
u = iterate_function(op_inc)
i = u(1)
limit = (x) ->
	Math.pow (1 + (1/x)), x
t = transform ( [ limit, i ] )
showStream([50,t])
