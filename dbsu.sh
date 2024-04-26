# Usage: dbsu.sh <path> <key1>=<value1> <key2>=<value2> ...
#
# Example: dbsu.sh /opt/app/ db.host=localhost db.port=3306

if [ $# -lt 3 ]; then
  echo "Usage: $0 <path> <key1>=<value1> <key2>=<value2> ..."
  exit 1
fi

path=$1

if [ ! -d "$path" ]; then
  echo "Error: $path does not exist"
  exit 1
fi

key_value_pairs=("${@:2}")

for key_value_pair in "${key_value_pairs[@]}"; do
  key=$(echo "$key_value_pair" | cut -d'=' -f1)
  value=$(echo "$key_value_pair" | cut -d'=' -f2)

  # Find all dbsettings.properties files under the path
  find "$path" -name "dbsettings.properties" | while read -r file; do
    # Check if the key exists in the file
    if grep -q "^$key=" "$file"; then

      contents=$(<"$file")

      updated_contents=""
      while IFS= read -r line; do
        if [[ "$line" == "$key="* ]]; then
          # Replace the value
          line="$key=$value"
        fi
        updated_contents+="$line"$'\n'
      done <<< "$contents"

      # Write the updated contents back to the file
      echo "$updated_contents" > "$file"
      echo "Updated $file"
    fi
  done
done
