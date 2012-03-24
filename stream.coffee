empty = []

newNode = (head, tail) ->
	[head,tail]

head = (node) ->
	return undefined unless node?
	node[0]

is_promise = (item) ->
	typeof (item) == "function"

tail = (node) ->
	if is_promise( node[1] )
		node[1] = node[1]()
	node[1]

transform = (f,stream) ->
	newNode(f(head(stream)), ->transform(f, tail(stream)) )

iterate = (f) ->
	return (x0) ->
		s = newNode( x0, ->transform(f, s) )

drop = (node) ->
	return unless node?
	h = head(node)
	t = tail(node)
	if t == empty or not t?
		node = undefined
	else
		node[0] = t[0]
		node[1] = t[1]
	return h

say = (msg) ->
	console.log msg

f = (x) -> x+1
u = iterate(f)
n = u(2)
limit = (x) -> Math.pow(( 1 + (1/x)),x)
t = transform limit, n
say drop(t)
say drop(t)
say drop(t)
say drop(t)
#say "#{tail(n)}"


