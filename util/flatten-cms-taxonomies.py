import argparse
import json


def convert_json_to_model(input_file):
    with open(input_file, "r") as f:
        data_from_file = json.load(f)
        flatten_model = list()
        taxonomies = data_from_file.get('data')
        for taxonomy in taxonomies:
            taxonomy_id = taxonomy.get('id')
            taxonomy_name = taxonomy.get('name')
            flatten_model.append({"taxonomy_id": taxonomy_id, "taxonomy_name": taxonomy_name})
            concepts = taxonomy.get('concepts')

            flatten_model.extend(format_concepts(taxonomy_id, taxonomy_name, concepts))

    return flatten_model


def format_concepts(taxonomy_id, taxonomy_name, concepts, parent_id=None):
    flatten_concepts = []
    if len(concepts) < 1:
        return []

    for concept in concepts:
        concept_id = concept.get('id')
        flatten_concepts.append({"taxonomy_id": taxonomy_id, "taxonomy_name": taxonomy_name, "concept_id": concept_id,
                                 "concept_name": concept.get('name'), "parent_concept_id": parent_id})
        children = concept.get('children')
        if children is not None and len(children) > 0:
            flatten_concepts.extend(format_concepts(taxonomy_id, taxonomy_name, children, concept_id))

    return flatten_concepts


def generate_file(converted_model, input_file_name):
    output_file_name = f"flatten-{input_file_name}"
    with open(output_file_name, "w") as f:
        json.dump(converted_model, f, indent=4, ensure_ascii=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Flatten CMS taxonomies model for RDF conversion")
    parser.add_argument("input_file", help="Path to the input JSON file")
    args = parser.parse_args()

    try:
        converted_model = convert_json_to_model(args.input_file)
        generate_file(converted_model, args.input_file)
        print("The taxonomies from CMS is flattened success")
    except Exception as e:
        print("Error:", e.with_traceback())
