#!/bin/sh
# Maven Wrapper script
# This script downloads and runs the Maven wrapper jar if needed.

set -e

# Determine the project base directory
if [ -z "$MAVEN_PROJECTBASEDIR" ]; then
  MAVEN_PROJECTBASEDIR=$(cd "$(dirname "$0")" && pwd)
  export MAVEN_PROJECTBASEDIR
fi

WRAPPER_JAR="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.jar"
WRAPPER_PROPERTIES="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.properties"

# Read the distribution URL from the properties file
if [ -f "$WRAPPER_PROPERTIES" ]; then
  DIST_URL=$(grep 'distributionUrl' "$WRAPPER_PROPERTIES" | cut -d'=' -f2-)
  WRAPPER_URL=$(grep 'wrapperUrl' "$WRAPPER_PROPERTIES" | cut -d'=' -f2-)
fi

# Determine Maven home
MAVEN_HOME="$HOME/.m2/wrapper/dists/$(basename "$DIST_URL" .zip)"

if [ ! -d "$MAVEN_HOME" ]; then
  echo "Downloading Maven from $DIST_URL..."
  mkdir -p "$MAVEN_HOME"
  if command -v curl > /dev/null 2>&1; then
    curl -fsSL "$DIST_URL" -o "$MAVEN_HOME/maven.zip"
  elif command -v wget > /dev/null 2>&1; then
    wget -q "$DIST_URL" -O "$MAVEN_HOME/maven.zip"
  else
    echo "Error: curl or wget is required to download Maven" >&2
    exit 1
  fi
  unzip -q -o "$MAVEN_HOME/maven.zip" -d "$MAVEN_HOME"
  rm -f "$MAVEN_HOME/maven.zip"
fi

# Find the mvn executable
MVN=$(find "$MAVEN_HOME" -name mvn -type f -path "*/bin/mvn" | head -1)

if [ -z "$MVN" ]; then
  echo "Error: could not find mvn executable in $MAVEN_HOME" >&2
  exit 1
fi

chmod +x "$MVN"
exec "$MVN" "$@"
