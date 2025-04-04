
#!/bin/bash

set -e

LAMBDA_DIRS=("create-url" "retrieve-url")
cd lambdas

for dir in "${LAMBDA_DIRS[@]}"; do
  echo "Zipping $dir..."
  cd "$dir"
  pip install -r requirements.txt -t . > /dev/null
  zip -r "../$dir.zip" . > /dev/null
  cd ..
done

echo "Lambdas zipped successfully."
