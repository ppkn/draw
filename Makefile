dev:
	npx elm-live src/Main.elm --hot -- --output=main.js

build:
	mkdir -p dist
	cp index.html dist/
	cp style.css dist/
	elm make src/Main.elm --optimize --output=dist/main.js
