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

upto	= curry_n([3,range])([0,1]) #creates functions upto
upto2 = upto([2]) #creates iterators upto2

iter = upto2()

while ( v = iter() ) != empty
	console.log v
