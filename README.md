# artsdata-planet-footlight
Pipelines to load Footlight CMS into Artsdata

This repo's workflow:
1. Downloads data from Footlight CMS (workflow per calendar)
2. Converts JSON to RDF using mapping stored in the data directory.
3. Stores RDF output on S3
4. Publishes the RDF to Artsdata Databus


Report link to check on mismatched dates and event status between CMS and Artsdata.
