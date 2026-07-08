# scripts/lib/stages.sh
# Single source of truth for the 6 PDLC stage names -- sourced by
# scaffold.sh and status.sh, which previously hand-duplicated this array
# identically in both files (entry 0035). Meant to be sourced, not
# executed directly.

STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)
