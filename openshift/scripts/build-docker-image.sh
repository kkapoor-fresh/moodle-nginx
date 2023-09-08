test -n "$BRANCH"
test -n "$BUILD_NAMESPACE"
echo "BUILIDING $DEPLOYMENT_NAME with tag: $BRANCH"
  oc -n $BUILD_NAMESPACE process --param-file=example.env -f ./openshift/docker-build.yml \
    -p NAME=$DEPLOYMENT_NAME \
    -p DOCKER_FROM_IMAGE=$DOCKER_FROM_IMAGE \
    -p IMAGE_REPO=$IMAGE_REPO \
    -p IMAGE_NAME=$DEPLOYMENT_NAME \
    -p IMAGE_TAG=$BASE_IMAGE_TAG \
    -p SOURCE_REPOSITORY_URL=$SOURCE_REPOSITORY_URL \
    -p DOCKER_FILE_PATH=$DOCKER_FILE_PATH \
    -p SOURCE_CONTEXT_DIR=$SOURCE_CONTEXT_DIR | oc -n $BUILD_NAMESPACE apply -f -
oc -n $BUILD_NAMESPACE start-build bc/$DEPLOYMENT_NAME --commit=$BRANCH --no-cache --wait
