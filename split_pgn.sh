#!/bin/bash

# Functions
# print error and exit in case theres not enough args
print_err_and_exit() {
    echo "Usage: $0 <source_pgn_file> <destination_directory>"
    exit 1
}

# check if file exists
check_file_exist() {
    if [ ! -f "$1" ]; then
        echo "Error: File '$1' does not exist."
        exit 1
    fi
}

# create dest directory if does not exist
create_dir_if_not_exist() {
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir"
        echo "Created directory '$dest_dir'."
    fi
}

# Function to split the PGN file into individual game files
split_pgn_file() {
    input_file="$1"
    dest_dir="$2"
    game_index=1
    game_content=""

    # loop that reads line to "line" var and runs while its not empty
    # the first condition reads lines to line var, the second makes sure we run until there is no more games to read.
    while IFS= read -r line || [ -n "$line" ]; do
        # we look for '[Event ' in the line beacuse every game starts with '[Event...' in the meta data.
        if [[ "$line" =~ ^\[Event\ \" ]]; 
        then
            # if game content is not empty, write it to the corresponding file.
            if [ -n "$game_content" ];
            then
                echo "$game_content" > "$dest_dir/game_$game_index.pgn"

                # increment the index and clear the content var for the next game.
                game_index=$((game_index + 1))  
                game_content=""
            fi
        fi
        # append new line to the file with new line character
        game_content+="$line"$'\n'
    done < "$input_file"    # for the last game, not handled in the loop 

    if [ -n "$game_content" ]; then
        echo "$game_content" > "$dest_dir/game_$game_index.pgn"
    fi
}

# The script

# Validate number of arguments
if [ "$#" -ne 2 ];
then
    print_err_and_exit
fi

input_file="$1"
dest_dir="$2"

# check existence of source file
check_file_exist "$input_file"

# check if destination directory exists and if not create it
create_dir_if_not_exist "$dest_dir"

# Split the PGN file into individual game PGN files
split_pgn_file "$input_file" "$dest_dir"

echo "Split completed. Games saved in '$dest_dir'."
