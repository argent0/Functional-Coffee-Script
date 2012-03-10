empty = []	#the empty iterator

range = (args...) ->
   from = args[0][0]
   to = args[0][1]
   step = args[0][2]

   value = from-step
   return ->
      return value=value+step if value < to
      return empty

curry = (f) ->
   ret = (firstArg,args...) ->
      console.log args.join ','
      r = (all...) ->
         f([firstArg].concat(all))
      return r


upto = curry(range)(0)

#upto = (x) ->
#   y = 0
#   return ->
#      return y++ if y < x
#      return empty

iter = upto(2,1)
while ( v = iter() ) != empty
   console.log v
