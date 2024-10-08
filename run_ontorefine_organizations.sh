#!/bin/bash

# Update the Config file
cms_file="ontotext-refine/cms-organizations-configuration.json"
column_additions_file="ontotext-refine/column-additions/organization.json"
jq '.operations |= (input + .)' $cms_file $column_additions_file > updated-cms-organizations-configuration.json

# Start the services in the background
sudo docker compose up -d

# Wait for the server to start
echo "Waiting for server to start..."
while ! curl --output /dev/null --silent --head --fail http://localhost:7333; do
  sleep 5
done
echo "Server started!"

# Send a command to the running container
echo "Running OntoRefine CLI using config.json..."
sudo docker exec onto_refine /opt/ontorefine/dist/bin/ontorefine-cli transform ../data/dump/organizations.json \
  -u http://localhost:7333  \
  --no-clean \
  --configurations ../data/updated-cms-organizations-configuration.json  \
  -f json >> organization-entities.ttl

# Open the default browser
open http://localhost:7333

echo "Open Project to edit the RDF Mapping."
