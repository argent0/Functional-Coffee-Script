stream.js: stream.coffee iterator.js
	coffee -c $<

iterator.js: iterator.coffee
	coffee -c $<

.PHONY : clean

clean:
	rm stream.js
	rm iterator.js
