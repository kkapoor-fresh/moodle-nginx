test -n "$DEPLOY_NAMESPACE"
test -n "$BRANCH"
echo "Current namespace is $DEPLOY_NAMESPACE"

# Create ConfigMaps
oc create configmap $WEB_DEPLOYMENT_NAME-config --from-file=./config/nginx/default.conf
oc create configmap $APP-config --from-file=./config/moodle/config.php

oc -n $DEPLOY_NAMESPACE process -f openshift/template.json \
      -p APP_NAME=$APP \
      -p DB_USER=$DB_USER \
      -p DB_NAME=$DB_NAME \
      -p DB_PASSWORD=$DB_PASSWORD \
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

echo "Rolling out $PHP_DEPLOYMENT_NAME..."

oc rollout latest dc/$PHP_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE

# Check PHP deployment rollout status every 10 seconds (max 10 minutes) until complete.
ATTEMPTS=0
WAIT_TIME=5
ROLLOUT_STATUS_CMD="oc rollout status dc/$PHP_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 120 ]; do
  $ROLLOUT_STATUS_CMD
  ATTEMPTS=$((attempts + 1))
  echo "$(($ATTEMPTS * $WAIT_TIME))..."
  sleep $WAIT_TIME
done

# Migrate build files to web root (/app/public to /var/www/html)
echo "Copying build files to web root on $PHP_DEPLOYMENT_NAME"
# Ensure moodle config is cleared
oc exec dc/$PHP_DEPLOYMENT_NAME -- bash -c 'rm -I /var/www/html/config.php' -n $DEPLOY_NAMESPACE
# Copy / update all files from docker build to shared PVC
oc exec dc/$PHP_DEPLOYMENT_NAME -- bash -c 'cp -ru /app/public/* /var/www/html' -n $DEPLOY_NAMESPACE

echo "Rolling out $CRON_DEPLOYMENT_NAME..."

oc rollout latest dc/$CRON_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE

# Check CRON deployment rollout status every 10 seconds (max 10 minutes) until complete.
# ATTEMPTS=0
# ROLLOUT_STATUS_CMD="oc rollout status dc/$CRON_DEPLOYMENT_NAME -n $DEPLOY_NAMESPACE"
# until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
#   $ROLLOUT_STATUS_CMD
#   ATTEMPTS=$((attempts + 1))
#   sleep 10
# done

echo "Listing pods..."

# oc get pods|grep $PHP_DEPLOYMENT_NAME
# sleep 30
# oc get pods -l deploymentconfig=$PHP_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name
# sleep 20
# podNames=$(oc get pods -l deploymentconfig=$PHP_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name)
# pwd
echo "$PHP_DEPLOYMENT_NAME is deployed"
echo "deploy1=$PHP_DEPLOYMENT_NAME is deployed" >> $GITHUB_OUTPUT

# oc get pods|grep $CRON_DEPLOYMENT_NAME
# sleep 30
# oc get pods -l deploymentconfig=$CRON_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name
# sleep 20
# podNames=$(oc get pods -l deploymentconfig=$CRON_DEPLOYMENT_NAME --field-selector=status.phase=Running -o name)
# pwd
echo "$CRON_DEPLOYMENT_NAME is deployed"
echo "deploy2=$CRON_DEPLOYMENT_NAME is deployed" >> $GITHUB_OUTPUT

# Deploy backups (** moved to deploy.yml)
# helm repo add bcgov http://bcgov.github.io/helm-charts
# helm upgrade --install db-backup-storage bcgov/backup-storage
