#! /bin/bash
set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUCKET=benlimmer.com

rm -fr _site
JEKYLL_ENV=production bundle exec jekyll build
cd _site || exit

# Sync Site
"$GOPATH"/bin/s3deploy \
    -config "$ROOT_DIR"/.s3deploy.yml \
    -region us-east-1 \
    -bucket "$BUCKET" \
    -distribution-id E1J0ZU49NLG2H2

# Create redirects
create_redirect() {
  local old_path="$1"
  local redirect_location="$2"

  aws s3api put-object \
    --bucket $BUCKET \
    --acl public-read \
    --key "$old_path" \
    --website-redirect-location "$redirect_location" \
    --no-cli-pager \
    --query 'ETag'
}

create_redirect "consulting/index.html" "/freelance"
create_redirect "consulting/contact/index.html" "/freelance/contact"
