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
  - class: InitialWorkDirRequirement
    listing:
      - entryname: sort_bgzip_index_vcf.sh
        entry:
          $include: ../scripts/sort_bgzip_index_vcf.sh

baseCommand: ["/bin/bash"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      sort_bgzip_index_vcf.sh
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.input_vcf.basename).gz

inputs:
  input_vcf: {type: File, doc: "vcf to sort", inputBinding: { position: 0 } }

outputs:
  gzipped_vcf:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: ['.tbi']
