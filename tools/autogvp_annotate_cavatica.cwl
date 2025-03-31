cwlVersion: v1.2
class: CommandLineTool
id: autogvp_annotate_cavatica
doc: |
  Tool for the 02-annotate_variants_CAVATICA_input.R script from AutoGVP
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/diskin-lab/autogvp:v1.0.3'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      Rscript /rocker-build/02-annotate_variants_CAVATICA_input.R --outdir .

inputs:
  vcf_file: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "Input vcf file with VEP annotations" }
  clinvar_file: { type: 'File?', inputBinding: { position: 2, prefix: "--clinvar" }, doc: "specific clinVar file (format: clinvar_20211225.vcf.gz)" }
  multianno_file: { type: 'File', inputBinding: { position: 2, prefix: "--multianno" }, doc: "input multianno file" }
  autopvs1_file: { type: 'File', inputBinding: { position: 2, prefix: "--autopvs1" }, doc: "input autopvs1 file" }
  intervar_file: { type: 'File', inputBinding: { position: 2, prefix: "--intervar" }, doc: "input intervar file" }
  variant_summary: { type: 'File', inputBinding: { position: 2, prefix: "--variant_summary" }, doc: "variant_summary file (format: variant_summary_2023-02.txt)" }
  output_basename: { type: 'string?', default: "test", inputBinding: { position: 2, prefix: "--output" }, doc: "String to use as base for output filenames" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task" }
outputs:
  annotation_report: { type: 'File', outputBinding: { glob: '*.cavatica_input.annotations_report.abridged.tsv' }}
