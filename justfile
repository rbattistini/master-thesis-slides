build:
    typst compile main.typ main.pdf

sync:
    git add -A
    git commit -m "Sync {{`date +'%Y-%m-%d %H:%M:%S'`}}"
