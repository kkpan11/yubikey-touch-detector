default: release

app := "yubikey-touch-detector"
version := `git describe --tags`

release: clean vendor
    mkdir -p dist
    git archive -o "dist/{{app}}-{{version}}.tar.gz" --format tar.gz --prefix "{{app}}-{{version}}/" "{{version}}"
    git archive -o "dist/{{app}}-{{version}}-src.tar.gz" --format tar.gz `find vendor -type f -printf '--prefix={{app}}-{{version}}/%h/ --add-file=%p '` --prefix "{{app}}-{{version}}/" "{{version}}"

    for file in dist/*; do \
        gpg --detach-sign --armor "$file"; \
    done

    rm -f "dist/{{app}}-{{version}}.tar.gz"

run *args:
    go run main.go {{args}}

build:
    # if you are building from git-archive tarballs, no need to pass -ldflags, the version is already hardcoded in main.go
    go build -ldflags "-X main.version={{version}}" -o {{app}} main.go
    scdoc < '{{app}}.1.scd' > '{{app}}.1'

vendor:
    go mod tidy
    go mod vendor

clean:
    rm -f {{app}}
    rm -rf dist
    rm -rf vendor
