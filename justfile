build:
    typst compile main.typ main.pdf

sync:
    git add -A
    git commit -m "Sync {{`date +'%Y-%m-%d %H:%M:%S'`}}"

tag VERSION:
    TIMESTAMP=$(date +'%Y-%m-%dT%H%M%S') && git tag "{{VERSION}}-${TIMESTAMP}"

push VERSION:
    just sync
    just tag {{VERSION}}
    git push
    git push --tags
