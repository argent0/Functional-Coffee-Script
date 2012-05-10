# Iterators
@iterator = {} # create a object name space to export all functions

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

iRepeat = (value) ->
	return new Iterator ->
		return value

iTake = (n,iterator,defaultValue=undefined) ->
	# Takes n values from an itertator
	done = 0
	return new Iterator ->
		done = 1 if ( n? and n==0 )
		return iEmpty if done != 0
		n--
		v = iterator.next()
		return v if not iterator.empty
		return defaultValue if defaultValue?
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

iFold = (f) ->	#works on iterators
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

showIterator = (iterator) ->
	# Dumps iterator to stdout
	v = iterator.next()
	until iterator.empty
		say v
		v = iterator.next()

# Array-Iterator functions
iList = (array) ->
	l = array.length
	i = 0
	return new Iterator ->
		return iEmpty if i>=l
		array[i++]

iCycle = (array,trigger=undefined) ->
	# cycles an array indefinitely
	# optional trigger to call when a cycle is done
	# returns an iterator
	l = array.length
	i = 0
	return new Iterator ->
		if i >= l
			i=0
			trigger() if trigger?
		return array[i++]


iCoCycle = (array,n,trigger=undefined) ->
	#Same as cycle but n times. Returns an iterator
	return undefined if ( not n? or ( n <=0 ) )
	if n == 1
		return iCycle(array,trigger)

	l = array.length
	i = 0
	
	reset = ->
		i++

	subCycle = iCoCycle(array,n-1,reset)
	
	return new Iterator ->
		s = subCycle.next()
		if i >= l
			i=0
			trigger() if trigger?
		return [array[i]].concat(s) if i < l

@iterator.Iterator = Iterator
@iterator.iEmpty = iEmpty
@iterator.iTake = iTake
@iterator.iZip = iZip
@iterator.iGrep = iGrep
@iterator.iMap = iMap
@iterator.iConcat = iConcat
@iterator.iFold = iFold
@iterator.iList = iList
@iterator.iCycle = iCycle
@iterator.iCoCycle = iCoCycle
@iterator.iRepeat = iRepeat
