#!/bin/bash

#!/bin/env bash
fonts=$(curl -s 'https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts' -H 'User-Agent: Mozilla/5.0 [...]')
font_names=$(echo "$fonts" | jq -r ".payload.tree.items[].name")
script_prefix="nf-"


PS3="Please, select a font to install: "
select font_name in $font_names; do
  if [ -n "$font_name" ]; then
    echo "You selected $font_name"
    break
  else
    echo "Please make a valid selection."
    exit 1
  fi
done

echo "Creating directory $HOME/.fonts/${script_prefix}${font_name}"
mkdir -p "$HOME/.fonts/${script_prefix}${font_name}"

echo ""

font_path_url="https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/${font_name}"
curr_dir=""

files_to_download=""

while true; do
  echo "running..."
  url="$font_path_url/$curr_dir"
  echo "url: $url"
  font_files_result=$(curl -s "$url" -H 'User-Agent: Mozilla/5.0 [...]')

  partial=$(echo "$font_files_result" | grep '"payload"' | sed "s/,\"richText\".*//")"}}}}"     
  font_files=$(echo "$partial" | jq -r ".payload.tree.items[].name" | grep -P "\.ttf|\.otf")

  if [[ $font_files == "" ]]; then
    # this means we are in a path with dirs
    files_info=$(echo "$partial" | jq -r -c ".payload.tree.items[]")
    dirs=""
    for file_info in $files_info; do
      contentType=$(echo "$file_info" | jq -r -c ".contentType")
      if [[ "$contentType" == "directory" ]]; then
        dirs+="$(echo "$file_info" | jq -r -c ".name") "
      fi
    done
  else
    PS3="Please, select a file to download: "
    select font_file in $font_files; do
      if [ -n "$font_file" ]; then
        files_to_download+="$font_file "
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
  fi

  #if dirs not empty 
  if [[ $dirs != "" ]]; then
    PS3="Please, select a directory: "
    select dir in $dirs; do
      if [ -n "$dir" ]; then
        curr_dir="$dir"
        dirs=""
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
  fi
done



# echo ""



# mkdir -p ~/.fonts

# dir_name="${HOME}/.fonts/${prefixo}${font_name}"
# mkdir -p "$dir_name"

# curl -fLo "${dir_name}/${font_name}-Regular.ttf" "${base_url}/${font_name}/Regular/${font_name}:Nerd Font Complete.ttf"
# curl -fLo "${dir_name}/${font_name}-Italic.ttf" "${base_url}/${font_name}/Italic/${font_name} Italic Nerd Font Complete.ttf"
# curl -fLo "${dir_name}/${font_name}-Bold.ttf" "${base_url}/${font_name}/Bold/${font_name} Bold Nerd Font Complete.ttf"


