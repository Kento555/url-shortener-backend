#!/bin/bash

set -e

LAMBDA_DIRS=("create-url" "retrieve-url")
cd lambdas

for dir in "${LAMBDA_DIRS[@]}"; do
  echo "Zipping $dir..."
  cd "$dir"
  pip install -r requirements.txt -t . > /dev/null
  zip -r "../../$dir.zip" . > /dev/null
  cd ..
done

cd ..
# Move zips into the infra/ directory so Terraform can read them
# Move zips into root so Terraform can read them correctly
mv create-url.zip ../
mv retrieve-url.zip ../

echo "Lambdas zipped and moved to infra/ successfully."
find . -maxdepth 1 -type f \( -name "create-url.zip" -o -name "retrieve-url.zip" \) | sed -e "s|^\./|./|" -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
