# artsdata-planet-footlight
Pipelines to load Footlight CMS into Artsdata

This repo's workflow:
1. Downloads data from Footlight CMS (workflow per calendar)
2. Converts JSON to RDF using mapping stored in the data directory.
3. Stores RDF output on S3
4. Publishes the RDF to Artsdata Databus

To edit RDF mapping:
1. Run `./run_ontorefine_events.sh` (if needed `chmod +x run_ontorefine_events.sh`)
2. Open localhost:7333 to use Open Refine workbench
3. Open the existing project
4. Click "Edit RDF Mapping"
5. When done making changes save RDF Mapping
6. Clean up the history (tab undo/redo) to keep only the steps needed.
6. Export > Export project configurations into Github /ontorefine/config.json
Note: create a different file to edit people, places and orgs.

Maintenance Reports
===========
[Check](http://kg.artsdata.ca/query/show?sparql=https://raw.githubusercontent.com/culturecreates/artsdata-planet-footlight/main/sparql/cms-event-start-date-mismatch.sparql&title=Mismatched+dates+and+event+status) on mismatched dates and event status between CMS and Artsdata.
