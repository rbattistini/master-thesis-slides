sync:
    git add -A
    git commit -m "Sync {{`date +'%Y-%m-%d %H:%M:%S'`}}"

tag:
    VERSION="0.1.0"
    TIMESTAMP=$(date +'%Y-%m-%dT%H%M%S')
    git tag "${VERSION}-${TIMESTAMP}"

push: sync tag
    git push
    git push --tags
