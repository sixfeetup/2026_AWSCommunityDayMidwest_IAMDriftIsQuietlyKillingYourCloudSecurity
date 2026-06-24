slide-theme := sixie_purple
slides-pdf := slides.pdf
decktape-size := 1200x675
chrome-path ?=

index.html: slides.md js/reveal.js dist/theme/$(slide-theme).css ## build presentation and theme
	pandoc -t revealjs -s -V revealjs-url=. \
		-V theme=$(slide-theme) \
		-V width=1200 \
		-V height=675 \
		-V center=false \
		-V autoPlayMedia=false \
		-V hash=true \
		-o "$@" "$<"

js/reveal.js:
	curl -LO https://github.com/hakimel/reveal.js/archive/master.zip
	bsdtar --strip-components=1 --exclude .gitignore --exclude LICENSE --exclude README.md --exclude demo.html --exclude index.html -xf master.zip
	rm master.zip
	npm install
	@# Copy built plugins to paths expected by Pandoc's revealjs template
	@for p in notes search zoom math highlight markdown; do \
		if [ -f dist/plugin/$$p.js ]; then \
			mkdir -p plugin/$$p; \
			cp dist/plugin/$$p.js plugin/$$p/$$p.js; \
		fi; \
	done

css/theme/$(slide-theme).scss: themes/$(slide-theme).scss
	cp "$<" "$@"

dist/theme/$(slide-theme).css: css/theme/$(slide-theme).scss
	npm run build:styles

reload-theme: dist/theme/$(slide-theme).css ## rebuild theme CSS and trigger Vite reload
	touch index.html

$(slides-pdf): index.html
	@chrome_path="$(chrome-path)"; \
	if [ -z "$$chrome_path" ] && [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then \
		chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; \
	fi; \
	if [ -n "$$chrome_path" ]; then \
		npx --yes decktape reveal -s $(decktape-size) --chrome-path="$$chrome_path" --chrome-arg=--allow-file-access-from-files "file://$(CURDIR)/index.html" "$@"; \
	else \
		npx --yes decktape reveal -s $(decktape-size) --chrome-arg=--allow-file-access-from-files "file://$(CURDIR)/index.html" "$@"; \
	fi

pdf: $(slides-pdf) ## build the slides as a PDF with Decktape

decktape: pdf ## build the slides as a PDF with Decktape

start: index.html ## bulid presentation and start server
	@echo "Starting the local presentation server 🚀"
	@npm run dev

clean: ## clean up the working directory
	rm CONTRIBUTING.md || true
	rm LICENSE || true
	rm -rf css/ || true
	rm index.html || true
	rm -rf examples/ || true
	rm -rf js/ || true
	rm -rf public/ || true
	rm package-lock.json || true
	rm package.json || true
	rm -rf plugin/ || true
	rm -rf scripts/ || true
	rm -rf test/ || true
	rm -rf node_modules/ || true
	rm -rf dist/ || true
	rm -rf react/ || true
	rm tsconfig.json || true
	rm tsconfig.node.json || true
	rm vite.config.ts || true
	rm vite.config.styles.ts || true

watch: ## Watch for changes and rebuild
	@echo "♻️ Watching for changes..."
	@watchmedo tricks-from tricks.yaml

help: ## This help.
	@awk 'BEGIN 	{ FS = ":.*##"; target="";printf "\nUsage:\n  make \033[36m<target>\033[33m\n\nTargets:\033[0m\n" } \
		/^[a-zA-Z_-]+:.*?##/ { if(target=="")print ""; target=$$1; printf " \033[36m%-10s\033[0m %s\n\n", $$1, $$2 } \
		/^([a-zA-Z_-]+):/ {if(target=="")print "";match($$0, "(.*):"); target=substr($$0,RSTART,RLENGTH) } \
		/^\t## (.*)/ { match($$0, "[^\t#:\\\\]+"); txt=substr($$0,RSTART,RLENGTH);printf " \033[36m%-10s\033[0m", target; printf " %s\n", txt ; target=""} \
		/^## .*/ {match($$0, "## (.+)$$"); txt=substr($$0,4,RLENGTH);printf "\n\033[33m%s\033[0m\n", txt ; target=""} \
	' $(MAKEFILE_LIST)

.PHONY: help clean start watch reload-theme pdf decktape
