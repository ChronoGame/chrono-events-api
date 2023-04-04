


set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo $DIR

DEPLOYMENT_NUMBER="$(date -u +%FT%TZ)"
echo "$DEPLOYMENT_NUMBER" > "$DIR/deployment_number"

cat "$DIR/variables.tf"

PROJECT_NAME="$(cat "$DIR/variables.tf" | grep 'project_name' -A 2 | grep 'default' | cut -d '=' -f 2 | cut -d '"' -f 2)"
echo $PROJECT_NAME


pushd "$DIR"
    zip -r hello_world.zip index.py
    aws s3 cp ./hello_world.zip "s3://$PROJECT_NAME/deployment/$DEPLOYMENT_NUMBER/hello_world.zip" --profile tylerw
popd


terraform apply -auto-approve -var deployment_number="$DEPLOYMENT_NUMBER"
