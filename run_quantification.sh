#!/bin/bash

# Check that two arguments were provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_folder> <output_folder>"
  exit 1
fi

# Define input directory
INPUT_FOLDER=$1

# Define output directory
OUTPUT_FOLDER=$2

# Feedback
echo "🔍 Input folder: $INPUT_FOLDER"
echo "📂 Output folder: $OUTPUT_FOLDER"

echo "📄 CSV files:"
ls "$INPUT_FOLDER"/*.csv

# Pass the output directory and input file to pipeline
Rscript ./scripts/plotQuantification.R "$INPUT_FOLDER" "$OUTPUT_FOLDER"

echo "✅ Done!"