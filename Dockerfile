# This directory will contain all code related to the autoiXpert Lambda function.
ARG FUNCTION_DIR="/function"

#*****************************************************************************
#  Builder Stage
#****************************************************************************/
FROM node:lts-alpine AS builder

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# The working directory is where "npm install" created the node_modules folder.
WORKDIR ${FUNCTION_DIR}

# Install aws-lambda-cpp build dependencies. aws-lambda-cpp is used by aws-lambda-ric which is a
# node-gyp compiled dependency. Find it in package.json.
# See the Node.js example at https://github.com/aws/aws-lambda-nodejs-runtime-interface-client
# and the python-based custom docker image example at https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
RUN apk add --no-cache \
    libstdc++ \
    build-base \
    libtool \
    autoconf \
    automake \
    libexecinfo-dev \
    make \
    cmake \
    libcurl \
    python3

# Copy dependencies. They usually don't change as often as the app code, so the dependency copy commands are placed here (before copying the app code). --> Docker Layers
RUN mkdir -p ${FUNCTION_DIR}
# Install the AWS Lambda Runtime Interface Client (RIC) that is only required within this Docker container (not in package.json on development machine).
# It helps AWS to run the Lambda function code that autoiXpert provides.
RUN npm install aws-lambda-ric

#*****************************************************************************
#  Production Stage
#****************************************************************************/
FROM node:lts-alpine

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# The working directory is where "npm install" created the node_modules folder.
WORKDIR ${FUNCTION_DIR}

# If this directory does not exist, lambda shows an annoying warning.
RUN mkdir -p /opt/extensions

COPY --from=builder ${FUNCTION_DIR}/node_modules ${FUNCTION_DIR}/node_modules
