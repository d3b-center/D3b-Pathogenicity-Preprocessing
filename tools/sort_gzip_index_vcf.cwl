cwlVersion: v1.2
class: CommandLineTool
id: sort_gzip_index_vcf
doc: "Quick tool to sort, compress and index a vcf file"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 8
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest'

baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      bcftools sort
  - position: 1
    shellQuote: false
    valueFrom: >-
      | bgzip -@ 8
  - position: 2
    shellQuote: false
    valueFrom: >-
      > $(inputs.input_vcf.basename).vcf.gz && tabix $(inputs.input_vcf.basename).vcf.gz 

inputs:
  input_vcf: {type: File, doc: "vcf to sort", inputBinding: { position: 0 } }

outputs:
  gzipped_vcf:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: ['.tbi']
