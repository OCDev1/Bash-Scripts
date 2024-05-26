#!/bin/bash

# Function to display the chess board
display_board() {
    echo -e "\nMove $move_count/$total_moves"
    echo "  a b c d e f g h"
    for ((i = 0; i < 8; i++)); do
        echo "$((8 - i)) ${board[$i]}  $((8 - i))"
    done
    echo "  a b c d e f g h"
}

# Function to initialize the chess board
init_board() {
    board=(
        "r n b q k b n r"
        "p p p p p p p p"
        ". . . . . . . ."
        ". . . . . . . ."
        ". . . . . . . ."
        ". . . . . . . ."
        "P P P P P P P P"
        "R N B Q K B N R"
    )
}

# Function to handle moving forward
move_forward() {
    if [ $move_count -lt $total_moves ]; then
        update_board "${moves_history[$move_count]}"
        ((move_count++))
        display_board
    else
        echo "No more moves available."
    fi
}

# Function to handle moving backward
move_backward() {
    if [ $move_count -gt 0 ]; then
        init_board
        ((move_count--))
        curr_move=0
        while [ $curr_move -lt $move_count ]; do
            update_board "${moves_history[$curr_move]}"
            ((curr_move++))
        done
        display_board
    else
        echo "Already at the start."
    fi
}

# Function to reset to start
reset_to_start() {
    move_count=0
    init_board
    display_board
}

# Function to move to the end
move_to_end() {
    while [ $move_count -lt $total_moves ]; do
        if [ $move_count -lt $total_moves ]; then
        ((move_count++))
        update_board "${moves_history[$move_count]}"
    else
        echo "No more moves available."
    fi
    done
    display_board
}

# Function to update the board after a move
update_board() {
    move=$1
    if [ -z "$move" ]; then
        echo "Error: Move string is empty."
        return 1
    fi

    if [[ ! $move =~ ^[a-h][1-8][a-h][1-8]$ ]]; then
        echo "Error: Invalid move format: $move"
        return 1
    fi

    from_col=$(( ( ( $(printf "%d" "'${move:0:1}") - 97 ) * 2 ) ))
    from_row=$(( 8 - ${move:1:1} ))
    to_col=$(( ( ( $(printf "%d" "'${move:2:1}") - 97 ) * 2 ) ))
    to_row=$(( 8 - ${move:3:1} ))

    piece=${board[$from_row]:$from_col:1}
    board[$from_row]="${board[$from_row]:0:$from_col}.${board[$from_row]:$((from_col + 1))}"
    board[$to_row]="${board[$to_row]:0:$to_col}$piece${board[$to_row]:$((to_col + 1))}"
}
# Main script

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pgn_file>"
    exit 1
fi

# Check if parse_moves.py exists
if [ ! -f "parse_moves.py" ]; then
    echo "Error: parse_moves.py not found."
    exit 1
fi

# Initialize the chess board
init_board

echo "Metadata from PGN file:"
cat "$1" | grep -E "\[Event|Site|Date|Round|White|Black|Result|WhiteElo|BlackElo|EventDate|ECO \]"

# Parse moves from PGN file using parse_moves.py
# Extract moves from the PGN file, excluding metadata
PGN_FILE="$1"
# moves_temp=$(grep -vE '^\[.*\]$' "$PGN_FILE" | tr -d '\n' | sed 's/[0-9]\+\. //g')

# DEBUG
# Extract moves from the PGN file, excluding metadata, and write to "temp" file
moves=$(grep -vE '^\[.*\]$' "$PGN_FILE" | tr '\n' ' ' | sed 's/[0-9]\+\. //g')

# Parse moves using parse_moves.py
parsed_moves=$(python3 parse_moves.py "$moves" 2>/dev/null)
moves_history=($parsed_moves)
total_moves=${#moves_history[@]}
move_count=0


display_board

# Interactive loop for user input
while true; do
    read -n 1 -p "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit: " key
    echo ""

    case $key in
    d) move_forward ;;
    a) move_backward ;;
    w) reset_to_start ;;
    s) move_to_end ;;
    q) echo "Exiting."; exit 0 ;;
    *) echo "Invalid key pressed: $key" ;;
    esac
done
