#!/bin/bash

#!/bin/env bash
fonts=$(
  curl -s 'https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts' \
    -H 'User-Agent: curl'
)
font_names=$(
  echo "$fonts" 
  | jq -r ".payload.tree.items[].name"
)
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

if [ -d "$HOME/.fonts/${script_prefix}${font_name}" ]; then
  echo "Font $font_name already installed. Skipping dir creation."
else
  echo "Creating directory $HOME/.fonts/${script_prefix}${font_name}"
  mkdir -p "$HOME/.fonts/${script_prefix}${font_name}"
fi

echo ""

font_path_url="https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/${font_name}"
curr_dir=""

files_to_download=()

download_marked() {
  font_family=$1

  echo "The following file will be downloaded:"
  print_marked_files
  echo ""

  # checks if user confirms download
  read -p "Do you want to continue? " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for file in "${files_to_download[@]}"; do
      echo "Downloading https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/${font_family}/${file}"
      cd "$HOME/.fonts/${script_prefix}${font_family}/" && curl -sfLO "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/${font_family}/${file}"
      if [[ $? == 0 ]]; then
        echo "Downloaded $file"
      else
        echo "Failed to download $file"
      fi
    done
  else
    echo "Aborting..."
  fi
}

print_marked_files() {
  for file in "${files_to_download[@]}"; do
    echo "  $file"
  done
}

while true; do
  url="$font_path_url/$curr_dir"
  r=$(curl -s "$url" -H 'User-Agent: curl')
  partial=$(
    echo "$r" 
    | grep '"payload"' 
    | sed "s/,\"richText\".*//"
    )"}}}}"     

  font_files=($(
    echo "$partial" 
    | jq -r ".payload.tree.items[].name" 
    | grep -P "\.ttf|\.otf"
    ))

  if [[ $font_files == "" ]]; then
    # this means we are in a path with dirs
    files_info=$(
      echo "$partial" 
      | jq -r -c ".payload.tree.items[]"
    )
    dirs=()
    for file_info in $files_info; do
      contentType=$(
        echo "$file_info" 
        | jq -r -c ".contentType"
      )
      if [[ "$contentType" == "directory" ]]; then
        dirs+=($(echo "$file_info" | jq -r -c ".name"))
      fi
    done
    dirs+=("Back")
    PS3="Please, select a directory: "
    select dir in ${dirs[@]}; do
      if [ -n "$dir" ]; then
        curr_dir="$dir"
        dirs=""
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
  else
    PS3="Please, select a file to download: "
    font_files+=("Back")
    font_files+=("Accept")
    select font_file in ${font_files[@]}; do
      if [ "$font_file" == "Back" ]; then
        curr_dir=""
        break
      elif [ "$font_file" == "Accept" ]; then
        download_marked "$font_name"
        exit 0
      fi

      if [[ curr_dir != "" ]]; then
        font_file="$curr_dir/$font_file"
      fi

      files_to_download+=("$font_file")
    done
  fi
done



# echo ""



# mkdir -p ~/.fonts

# dir_name="${HOME}/.fonts/${prefixo}${font_name}"
# mkdir -p "$dir_name"

# curl -fLo "${dir_name}/${font_name}-regular.ttf" "${base_url}/${font_name}/Regular/${font_name}:Nerd Font Complete.ttf"
# curl -fLo "${dir_name}/${font_name}-Italic.ttf" "${base_url}/${font_name}/Italic/${font_name} Italic Nerd Font Complete.ttf"
# curl -fLo "${dir_name}/${font_name}-Bold.ttf" "${base_url}/${font_name}/Bold/${font_name} Bold Nerd Font Complete.ttf"


