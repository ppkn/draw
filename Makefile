dev:
	npx elm-live src/Main.elm --hot -- --output=main.js

build:
	elm make --optimize --output=main.js