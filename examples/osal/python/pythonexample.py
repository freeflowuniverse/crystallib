
import json

for counter in range(1, 11):  # Loop from 1 to 10
	print(f"done_{counter}")
 
print("==RESULT==")

# Define a simple Python structure (e.g., a dictionary)
example_struct = {
    "name": "John Doe",
    "age": 30,
    "is_member": True,
    "skills": ["Python", "Data Analysis", "Machine Learning"]
}

# Convert the structure to a JSON string
json_string = json.dumps(example_struct, indent=4)

# Print the JSON string
print(json_string)