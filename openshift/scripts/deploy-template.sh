test -n "$DEPLOY_NAMESPACE"
test -n "$BRANCH"
echo "Current namespace is $DEPLOY_NAMESPACE"

# Create ConfigMaps
oc create configmap $WEB_DEPLOYMENT_NAME-env --from-file=./config/nginx/default.conf

oc -n $DEPLOY_NAMESPACE process -f openshift/template.json \
      -p APP_NAME=$APP \
      -p BUILD_TAG=$BUILD_TAG \
      -p SITE_URL=$APP_HOST_URL \
      -p BUILD_NAMESPACE=$BUILD_NAMESPACE \
      -p DEPLOY_NAMESPACE=$DEPLOY_NAMESPACE \
      -p IMAGE_REPO=$IMAGE_REPO \
      -p WEB_DEPLOYMENT_NAME=$WEB_DEPLOYMENT_NAME \
      -p WEB_IMAGE=$WEB_IMAGE \
      -p CRON_IMAGE=$CRON_IMAGE \
      -p CRON_DEPLOYMENT_NAME=$CRON_DEPLOYMENT_NAME \
      -p PHP_DEPLOYMENT_NAME=$PHP_DEPLOYMENT_NAME | \
oc -n $DEPLOY_NAMESPACE apply -f -

oc rollout latest dc/$PHP_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE
oc rollout latest dc/$CRON_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE

# Check PHP deployment rollout status every 10 seconds (max 10 minutes) until complete.
# ATTEMPTS=0
# ROLLOUT_STATUS_CMD="oc rollout status dc/$PHP_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE"
# until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
#   $ROLLOUT_STATUS_CMD
#   ATTEMPTS=$((attempts + 1))
#   sleep 10
# done

# Check CRON deployment rollout status every 10 seconds (max 10 minutes) until complete.
# ATTEMPTS=0
# ROLLOUT_STATUS_CMD="oc rollout status dc/$CRON_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE"
# until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
#   $ROLLOUT_STATUS_CMD
#   ATTEMPTS=$((attempts + 1))
#   sleep 10
# done

oc project $DEPLOY_NAMESPACE
echo "Listing pods..."

# oc get pods|grep $PHP_DEPLOYMENT_NAME
# sleep 30
# oc get pods -l deploymentconfig=$PHP_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name
# sleep 20
# podNames=$(oc get pods -l deploymentconfig=$PHP_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name)
# pwd
echo "deploy1=$PHP_DEPLOYMENT_NAME is deployed" >> $GITHUB_OUTPUT

# oc get pods|grep $CRON_DEPLOYMENT_NAME
# sleep 30
# oc get pods -l deploymentconfig=$CRON_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name
# sleep 20
# podNames=$(oc get pods -l deploymentconfig=$CRON_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name)
# pwd
echo "deploy2=$CRON_DEPLOYMENT_NAME is deployed" >> $GITHUB_OUTPUT
