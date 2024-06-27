cwlVersion: v1.2
class: Workflow
id: autogvp
label: AutoGVP Workflow
doc: |
  # AutoGVP: Automated Germline Variant Pathogenicity Workflow

  This workflow is a Common Workflow Language (CWL) implementation of the
  [AutoGVP bash script](https://github.com/diskin-lab-chop/AutoGVP/blob/main/run_autogvp.sh).
  Other than downloading files, this workflow contains all the functionality of
  the bash script.

  AutoGVP is a "tool that integrates germline variant pathogenicity annotations
  from ClinVar and sequence variant classifications from a modified version of
  InterVar (PVS1 strength adjustments, removal of PP5/BP6). This tool facilitates
  large-scale, clinically focused classification of germline sequence variants in
  a research setting."

  Please refer to the [AutoGVP publication](https://doi.org/10.1093/bioinformatics/btae114)
  for a detailed description of the software.

  ## Inputs

  ```yaml
  workflow: Indicate whether the input VCF is from a cavatica or custom workflow
  vcf_file: Input VCF file. Can be either VEP-annotated VCF file or or VEP- and ClinVar-annotated VCF file
  filter_criteria: Any additional VCF filtering criteria
  clinvar_file: ClinVar file. Required for inputs from a custom workflow!
  intevar_file: InterVar results file
  autopsv1_file: AutoPVS1 results file
  multianno_file: ANNOVAR multianno file
  output_colnames: File with column name information
  output_basename: String to use as the basename for stored outputs
  selected_clinvar_submissions: ClinVar variant file with conflicts resolved. If not provided, this file will be generated in the workflow
  variant_summary_file: ClinVar variant summary file
  submission_summary_file: ClinVar submission summary file
  concept_ids: File containing list of conceptIDs to prioritize submissions for ClinVar variant conflict resolution
  conflict_res: How to resolve conflicts associated with conceptIDs: latest or most_severe
  ```

  The following files can be obtained from the [AutoGVP GitHub data directory](https://github.com/diskin-lab-chop/AutoGVP/tree/main/data):
  - `autopsv1_file`
  - `concept_ids`
  - `intevar_file`
  - `multianno_file`
  - `output_colnames`

  Additionally, AutoGVP provides [a bash script](https://github.com/diskin-lab-chop/AutoGVP/blob/main/scripts/download_db_files.sh) to obtain:
  - `clinvar_file`
  - `submission_summary_file`
  - `variant_summary_file`

  ## Outputs

  ```yaml
    abridged: output file with minimal information needed to interpret variant pathogenicity
    full: output file with >100 variant annotation columns
  ```

  ## Resources

  Dockerfile: pgc-images.sbgenomics.com/diskin-lab/autogvp:v1.0.1
  AutoGVP Paper: https://doi.org/10.1093/bioinformatics/btae114
  AutoGVP GitHub: https://github.com/diskin-lab-chop/AutoGVP
requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
inputs:
  workflow: {type: {type: enum, symbols: ["cavatica", "custom"], name: "workflow"}, doc: "Indicate whether the input VCF is from a
      cavatica or custom workflow"}
  vcf_file: {type: 'File', doc: "Input VCF file. Can be either VEP-annotated VCF file or or VEP- and ClinVar-annotated VCF file"}
  filter_criteria: {type: 'string[]?', doc: "Any additional VCF filtering criteria"}
  clinvar_file: {type: 'File?', doc: "ClinVar file. Required for inputs from a custom workflow!"}
  intevar_file: {type: 'File', doc: "InterVar results file"}
  autopsv1_file: {type: 'File', doc: "AutoPVS1 results file"}
  multianno_file: {type: 'File', doc: "ANNOVAR multianno file"}
  output_colnames: {type: 'File', doc: "File with column name information."}
  output_basename: {type: 'string?', default: "out", doc: "String to use as the basename for stored outputs."}
  selected_clinvar_submissions: {type: 'File?', doc: "ClinVar variant file with conflicts resolved. If not provided, this file will
      be generated in the workflow"}
  variant_summary_file: {type: 'File?', doc: "ClinVar variant summary file"}
  submission_summary_file: {type: 'File?', doc: "ClinVar submission summary file"}
  concept_ids: {type: 'File?', doc: "File containing list of conceptIDs to prioritize submissions for ClinVar variant conflict resolution"}
  conflict_res: {type: ['null', {type: enum, symbols: ["latest", "most_severe"], name: "conflict_resolution"}], doc: "How to resolve
      conflicts associated with conceptIDs: latest or most_severe"}
  annotate_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to AutoGVP annotation" }
  annotate_ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to AutoGVP annotation" }
  filter_annot_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to AutoGVP filter annotations" }
  filter_annot_ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to AutoGVP filter annotations" }
outputs:
  abridged: {type: 'File', outputSource: filter_annotations/abridged_output, doc: "output file with minimal information needed to
      interpret variant pathogenicity"}
  full: {type: 'File', outputSource: filter_annotations/full_output, doc: "output file with >100 variant annotation columns"}
steps:
  select_clinvar_subs:
    run: ../tools/autogvp_select_clinvar_subs.cwl
    when: $(inputs.selected_submissions == null)
    in:
      selected_submissions: selected_clinvar_submissions
      variant_summary: variant_summary_file
      submission_summary: submission_summary_file
      conceptid_list: concept_ids
      conflict_res: conflict_res
    out: [clinvar_submissions]
  filter_vcf:
    run: ../tools/autogvp_filter_vcf.cwl
    in:
      vcf_file: vcf_file
      multianno_file: multianno_file
      autopvs1_file: autopsv1_file
      intervar_file: intevar_file
      output_basename: output_basename
      filter_criteria: filter_criteria
    out: [filtered_vcf, filtered_multianno, filtered_autopsv, filtered_intervar]
  annotate_cavatica:
    run: ../tools/autogvp_annotate_cavatica.cwl
    when: $(inputs.workflow == "cavatica")
    in:
      workflow: workflow
      vcf_file: filter_vcf/filtered_vcf
      clinvar_file: clinvar_file
      multianno_file: filter_vcf/filtered_multianno
      autopvs1_file: filter_vcf/filtered_autopsv
      intervar_file: filter_vcf/filtered_intervar
      variant_summary:
        source: [selected_clinvar_submissions, select_clinvar_subs/clinvar_submissions]
        pickValue: first_non_null
      output_basename: output_basename
      cpu: annotate_cpu
      ram: annotate_ram
    out: [annotation_report]
  annotate_custom:
    run: ../tools/autogvp_annotate_custom.cwl
    when: $(inputs.workflow == "custom")
    in:
      workflow: workflow
      vcf_file: filter_vcf/filtered_vcf
      clinvar_file: clinvar_file
      multianno_file: filter_vcf/filtered_multianno
      autopvs1_file: filter_vcf/filtered_autopsv
      intervar_file: filter_vcf/filtered_intervar
      variant_summary:
        source: [selected_clinvar_submissions, select_clinvar_subs/clinvar_submissions]
        pickValue: first_non_null
      output_basename: output_basename
      cpu: annotate_cpu
      ram: annotate_ram
    out: [annotation_report]
  parse_vcf:
    run: ../tools/autogvp_parse_vcf.cwl
    in:
      vcf_file: filter_vcf/filtered_vcf
    out: [parsed_tsv, csq_subfields_tsv]
  filter_annotations:
    run: ../tools/autogvp_filter_annotations.cwl
    in:
      vcf_file: parse_vcf/parsed_tsv
      autogvp_file:
        source: [annotate_cavatica/annotation_report, annotate_custom/annotation_report]
        pickValue: the_only_non_null
      colnames_file: output_colnames
      csq_subfields: parse_vcf/csq_subfields_tsv
      output_basename: output_basename
      cpu: filter_annot_cpu
      ram: filter_annot_ram
    out: [abridged_output, full_output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
"sbg:links":
- id: 'https://github.com/d3b-center/D3b-Pathogenicity-Preprocessing/releases/tag/v1.2.0'
  label: github-release
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
