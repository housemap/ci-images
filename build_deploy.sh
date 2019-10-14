#!/bin/bash

# abort on errors and on unset variables
set -e -o nounset

MINIMAL_IMAGE=housemap/ci-images:minimal
MINIMAL_DOCKERFILE=minimal.Dockerfile

JAVA_IMAGE=housemap/ci-images:java
JAVA_DOCKERFILE=java.Dockerfile

ANDROID_IMAGE=housemap/ci-images:android
ANDROID_DOCKERFILE=android.Dockerfile

NODE_IMAGE=housemap/ci-images:node
NODE_DOCKERFILE=node.Dockerfile

SDKS=$(echo {29..22})
LATEST_SDKS=$(echo {29..27})
LATEST_PACKAGES=''; for SDK in $LATEST_SDKS; do LATEST_PACKAGES="platforms;android-${SDK} $LATEST_PACKAGES"; done

echo "SDKS = $SDKS"
echo "LATEST_SDKS = $LATEST_SDKS"
echo "LATEST_PACKAGES = $LATEST_PACKAGES"

docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD

build_deploy_minimal() {
    echo "Building 'minimal' image…"
    docker build --tag $MINIMAL_IMAGE --file $MINIMAL_DOCKERFILE .
    docker push $MINIMAL_IMAGE
    echo
}

build_deploy_java() {
    echo "Building 'java' image…"
    docker build --tag $JAVA_IMAGE --file $JAVA_DOCKERFILE .
    docker push $JAVA_IMAGE
    echo
}

build_deploy_android() {
    echo "Building 'android' image…"
    docker build --tag $ANDROID_IMAGE --file $ANDROID_DOCKERFILE .
    docker push $ANDROID_IMAGE
    echo
}

build_deploy_node() {
    echo "Building 'node' image…"
    docker build --tag $NODE_IMAGE --file $NODE_DOCKERFILE .
    docker push $NODE_IMAGE
    echo
}

build_deploy_minimal
build_deploy_java
build_deploy_android
build_deploy_node