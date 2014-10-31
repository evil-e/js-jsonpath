
all: build site

build:
	./node_modules/jison/lib/cli.js src/jsonpath.y src/jsonpath.l 
	mv jsonpath.js lib/parser.js
	node scripts/bundle.js > web/jsonpath.js #| ./node_modules/uglify-js/bin/uglifyjs > web/jsonpath.js

site:
	cp web/*  /www/href.xyz/htdocs/json/

