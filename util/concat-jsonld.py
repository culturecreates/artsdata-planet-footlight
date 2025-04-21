import json

def concatenate_jsonld(files):
    result = {"@context": {"@vocab": "http://schema.org/"}, "@graph": []}

    for file in files:
        try:
            with open(file, 'r') as f:
                data = json.load(f)
                if "@graph" in data:
                    result["@graph"].extend(data["@graph"])
        except json.JSONDecodeError as e:
            print(f"Error decoding {file}: {e}")
            continue

    return result

if __name__ == "__main__":

    if len(sys.argv) > 1:
        file_name = sys.argv[1]

    input_files = [ 'events.jsonld','people.jsonld', 'organizations.jsonld', 'places.jsonld', 'taxonomies.jsonld']
    combined_result = concatenate_jsonld(input_files)
    with open(file_name, 'w') as output_file:
        json.dump(combined_result, output_file, indent=2)
