set -e
cd "$(dirname "$0")"
function build_tree() {
    local dir="$1"
    local indent="$2"
    local first=1
    echo -n "${indent}{\"name\":\"$(basename "$dir")\",\"type\":\"directory\",\"children\":["
    for entry in "$dir"/*; do
        if [[ -d "$entry" ]]; then
            [[ $first -eq 0 ]] && echo -n ","
            build_tree "$entry" "$indent  "
            first=0
        fi
    done
    for entry in "$dir"/*; do
        if [[ -f "$entry" && "${entry##*.}" == "html" ]]; then
            [[ $first -eq 0 ]] && echo -n ","
            echo -n "${indent}  {\"name\":\"$(basename "$entry")\",\"type\":\"file\",\"path\":\"${entry#./}\"}"
            first=0
        fi
    done
    echo -n "]}"
}
echo "[" > html_tree.json
first=1
for entry in *; do
    if [[ -d "$entry" && "$entry" != ".git" && "$entry" != "node_modules" ]]; then
        [[ $first -eq 0 ]] && echo "," >> html_tree.json
        build_tree "$entry" "" >> html_tree.json
        first=0
    fi
done
for entry in *; do
    if [[ -f "$entry" && "${entry##*.}" == "html" ]]; then
        [[ $first -eq 0 ]] && echo "," >> html_tree.json
        echo "{\"name\":\"$entry\",\"type\":\"file\",\"path\":\"$entry\"}" >> html_tree.json
        first=0
    fi
done
echo "]" >> html_tree.json
