cwlVersion: v1.2
class: Workflow
id: autogvp
label: AutoGVP Workflow
doc: |-
  Workflow for AutoGVP
requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
inputs:
  workflow: { type: { type: enum, symbols: ["cavatica", "custom"], name: "workflow" }, doc: "Indicate whether the input VCF is from a cavatica or custom workflow" }
  vcf_file: { type: 'File', doc: "Input VCF file" }
  filter_criteria: { type: 'string[]?', doc: "VCF filtering criteria" }
  clinvar_file: { type: 'File?', doc: "clinvar file. Required for inputs from a custom workflow!" }
  intevar_file: { type: 'File', doc: "intervar results file" }
  autopsv1_file: { type: 'File', doc: "autopvs1 results file" }
  multianno_file: { type: 'File', doc: "multianno file" }
  output_colnames: { type: 'File', doc: "File with column name information." }
  output_basename: { type: 'string?', default: "out", doc: "String to use as the basename for stored outputs." }
  selected_clinvar_submissions: { type: 'File?', doc: "clinvar variant file with conflicts resolved" }
  variant_summary_file: { type: 'File?', doc: "ClinVar variant summary file" }
  submission_summary_file: { type: 'File?', doc: "ClinVar submission summary file" }
  concept_ids: { type: 'File?', doc: "File containing list of conceptIDs to prioritize submissions for clinvar variant conflict resolution." }
  conflict_res: {  type: ['null', { type: enum, symbols: ["latest", "most_severe"], name: "conflict_resolution" }], doc: "how to resolve conflicts associated with conceptIDs." }
outputs:
  abridged: { type: 'File', outputSource: filter_annotations/abridged_output }
  full: { type: 'File', outputSource: filter_annotations/full_output }
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
