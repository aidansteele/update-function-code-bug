#!/bin/bash
set -euxo pipefail

aws sts get-caller-identity

ZIP_FUNCTION=ufc-bug-ZipFunction-1J20KEU3TLYSM

mkdir zipdemo
cd zipdemo
date > somefile
zip func.zip somefile

aws lambda list-versions-by-function --function-name $ZIP_FUNCTION
aws lambda update-function-code --function-name $ZIP_FUNCTION --zip-file fileb://func.zip --publish
sleep 1
aws lambda list-versions-by-function --function-name $ZIP_FUNCTION

cd ..

IMAGE_FUNCTION=ufc-bug-ImageFunction-2XTCSKC95SZC
IMAGE_REPO=${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/repository-9shz3x5dxi6k
EPOCH=$(date +%s)

mkdir imagedemo
cd imagedemo
date > somefile
echo 'FROM scratch' >> Dockerfile
echo 'COPY . .' >> Dockerfile
docker build -t ${IMAGE_REPO}:${EPOCH} .
aws ecr get-login-password | docker login -u AWS --password-stdin ${IMAGE_REPO}
docker push ${IMAGE_REPO}:${EPOCH}

aws lambda list-versions-by-function --function-name $IMAGE_FUNCTION
aws lambda update-function-code --function-name $IMAGE_FUNCTION --image-uri ${IMAGE_REPO}:${EPOCH} --publish
sleep 1
aws lambda list-versions-by-function --function-name $IMAGE_FUNCTION
