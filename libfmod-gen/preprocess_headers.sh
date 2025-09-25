#!/bin/bash

# Preprocess FMOD 2.03.09 headers to handle new macros that break the parser

SDK_PATH="./fmod/20309"
PROCESSED_PATH="./fmod/20309_processed"

echo "Preprocessing FMOD 2.03.09 headers..."

# Create processed directory structure
rm -rf "$PROCESSED_PATH"
cp -r "$SDK_PATH" "$PROCESSED_PATH"

# Comment out problematic variadic macros with ##__VA_ARGS__
for file in "$PROCESSED_PATH"/api/core/inc/*.h "$PROCESSED_PATH"/api/studio/inc/*.h; do
    if [ -f "$file" ]; then
        # Comment out lines containing ##__VA_ARGS__ (these are just logging macros)
        sed -i 's/^\(.*##__VA_ARGS__.*\)$/\/\/ FMOD_2_03_VARIADIC_MACRO: \1/' "$file"
    fi
done

echo "Preprocessing complete. Use $PROCESSED_PATH for generation."