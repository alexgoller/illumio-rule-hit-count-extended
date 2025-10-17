#!/bin/bash

# Rule Hit Count Analysis - Example Commands
# Based on actual workflow for joining Illumio rule exports with custom data

# ============================================
# 1. Export Rules from Illumio PCE
# ============================================

echo "Step 1: Exporting rules from Illumio PCE..."

~/git/workloader/workloader rule-export --policy-version active

# This creates a file like: workloader-rule-export-YYYYMMDD_HHMMSS.csv

# ============================================
# 2. Basic Join - Combine Two CSV Files
# ============================================

echo "Step 2: Joining CSV files..."
# Join on matching columns: "Rule HREF" from rule-hit-count.csv and "rule_href" from workloader export
csvjoin -c "Rule HREF,rule_href" \
  rule-hit-count.csv \
  workloader-rule-export-20251013_155354.csv > rule-hit-count-joined.csv

# ============================================
# 3. Join and View Interactively
# ============================================

echo "Step 3: Join and view as formatted table..."
# Use csvlook to display the joined data in a readable table format
csvjoin -c "Rule HREF,rule_href" \
  rule-hit-count.csv \
  workloader-rule-export-20251013_155354.csv | csvlook

# ============================================
# 4. Join with Column Filtering
# ============================================

echo "Step 4: Join and exclude specific columns..."
# Exclude columns 1,2,7,8,9,10,11,12,13,14,15,16,17,18,19,41,42,43,44,45,46,47,48,49,50
# This helps focus on the most relevant data
csvjoin -c "Rule HREF,rule_href" \
  rule-hit-count.csv \
  workloader-rule-export-20251013_155354.csv | \
  csvcut -C 1,2,7,8,9,10,11,12,13,14,15,16,17,18,19,41,42,43,44,45,46,47,48,49,50,"" | \
  csvlook

# ============================================
# 5. Analyze the Workloader Export
# ============================================

echo "Step 5: Getting statistics on the export..."
# Get descriptive statistics for all columns
csvstat workloader-rule-export-20251013_155354.csv --csv

# ============================================
# 6. Additional Useful Commands
# ============================================

# Count rows in a CSV
csvstat rule-hit-count.csv --count

# View only specific columns (e.g., columns 1-5)
csvcut -c 1-5 rule-hit-count-joined.csv | csvlook

# Filter rows by column value
csvgrep -c "enabled" -m "true" workloader-rule-export-20251013_155354.csv | csvlook

# Sort by a column
csvsort -c "Rule HREF" rule-hit-count-joined.csv | csvlook

# Get column names
csvcut -n rule-hit-count-joined.csv

# Convert to JSON
csvjson rule-hit-count-joined.csv > rule-hit-count-joined.json

echo "Examples completed!"
