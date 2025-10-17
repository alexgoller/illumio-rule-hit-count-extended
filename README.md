# Rule Hit Count Analysis

A project for enriching Illumio Rule Hit Count reports with actual rule contents using csvtools.

## Overview

The Illumio UI's Rule Hit Count report shows how frequently rules are being triggered, but doesn't include the full rule details (source, destination, services, etc.). This project solves that by joining the Rule Hit Count data with exported rule contents.

This project demonstrates how to:
1. Export Rule Hit Count data from the Illumio UI
2. Export full rule details from Illumio PCE using workloader
3. Join the two datasets to see hit counts alongside actual rule contents
4. Filter and analyze the enriched dataset

## Rule Hit Count in Illumio UI

The Rule Hit Count feature is available in the Illumio Policy Compute Engine (PCE) user interface. This feature provides visibility into how frequently rules are being triggered in your environment.

**To access and export Rule Hit Count:**
1. Navigate to **Reports** in the Illumio UI
2. Select **Rule Hit Count**
3. Export the report to CSV

This report contains rule HREFs and hit count statistics, but lacks the actual rule configuration details. By joining this with the full rule export, you can analyze which specific rules (with their sources, destinations, and services) are most frequently used.

## Prerequisites

### Installing csvkit (csvtools)

csvkit is a suite of command-line tools for working with CSV files.

**On macOS:**
```bash
brew install csvkit
```

**On Ubuntu/Debian:**
```bash
sudo apt-get install csvkit
```

**Using pip:**
```bash
pip install csvkit
```

### Installing Illumio Workloader

Illumio workloader is a command-line tool for bulk operations with Illumio PCE.

**Installation:**
```bash
# Clone the workloader repository
git clone https://github.com/brian1917/workloader.git

# Build the binary (requires Go)
cd workloader
go build

# Or download pre-built binaries from:
# https://github.com/brian1917/workloader/releases
```

**Configuration:**
Set up your Illumio PCE credentials using the interactive configuration:
```bash
workloader pce-add
```

This will prompt you for the necessary information to connect to your PCE and create a `pce.yaml` configuration file. Run `workloader pce-add --help` for additional authentication options.

## Usage

### 1. Export Rule Hit Count from Illumio UI

First, export the Rule Hit Count report:
1. Navigate to **Reports → Rule Hit Count** in the Illumio UI
2. Export the report to CSV
3. Save it (e.g., as `rule-hit-count.csv`)

This CSV will contain rule HREFs and hit count statistics.

### 2. Export Full Rule Details from Illumio

Export the active policy rules with full details from your Illumio PCE:

```bash
~/git/workloader/workloader rule-export --policy-version active
```

This will create a CSV file named something like `workloader-rule-export-YYYYMMDD_HHMMSS.csv` containing full rule configurations (sources, destinations, services, etc.).

### 3. Join CSV Files

Join the Rule Hit Count data with the full rule details using matching rule HREFs:

```bash
csvjoin -c "Rule HREF,rule_href" rule-hit-count.csv workloader-rule-export-20251013_155354.csv > final.csv
```

Where:
- `rule-hit-count.csv` is the Rule Hit Count export from the UI with a column named "Rule HREF"
- `workloader-rule-export-*.csv` is the Illumio export with a column named "rule_href"
- `-c` specifies the columns to join on

### 4. Filter and View Data

**View specific columns:**
```bash
csvjoin -c "Rule HREF,rule_href" rule-hit-count.csv workloader-rule-export-20251013_155354.csv | \
  csvcut -C 1,2,7,8,9,10,11,12,13,14,15,16,17,18,19,41,42,43,44,45,46,47,48,49,50,"" | \
  csvlook
```

**Analyze the data:**
```bash
csvstat workloader-rule-export-20251013_155354.csv --csv
```

## Common csvkit Commands

- `csvjoin`: Join two CSV files on common columns
- `csvcut`: Select or exclude specific columns
- `csvlook`: Render CSV as a formatted table
- `csvstat`: Calculate descriptive statistics for CSV columns
- `csvgrep`: Filter CSV rows by column value
- `csvsort`: Sort CSV files

## Example Workflow

```bash
# 1. Export Rule Hit Count from UI (Reports → Rule Hit Count → Export)
# Save as rule-hit-count.csv

# 2. Export full rule details from Illumio PCE
~/git/workloader/workloader rule-export --policy-version active

# 3. Join Rule Hit Count with full rule details
csvjoin -c "Rule HREF,rule_href" \
  rule-hit-count.csv \
  workloader-rule-export-20251013_155354.csv > rule-hit-count-enriched.csv

# 4. View the enriched data (hit counts + rule contents)
csvlook rule-hit-count-enriched.csv

# 5. Get statistics on specific columns
csvstat rule-hit-count-enriched.csv --csv
```

## Resources

- [csvkit Documentation](https://csvkit.readthedocs.io/)
- [Illumio Workloader GitHub](https://github.com/brian1917/workloader)
- [Illumio API Documentation](https://docs.illumio.com/)
