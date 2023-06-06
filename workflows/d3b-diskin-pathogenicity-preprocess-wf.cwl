cwlVersion: v1.2
class: Workflow
id: d3b-diskin-pathogenicity-preprocess-wf
label: Pathogenicity Preprocessing Workflow
doc: |
  Runs InterVar and autoPVS1 on a VEP-annotated VCF
requirements:
- class: SubworkflowFeatureRequirement

inputs:
  # Common
  vep_vcf: { type: File, secondaryFiles: [.tbi], doc: "VCF file (with associated index) to be annotated" }
  buildver:  { type: ['null', { type: enum, symbols: ["hg38","hg19","hg18"], name: "buildver" } ], doc: "Genome reference build version",
    default: "hg38" }
  output_basename: { type: string, doc: "String that will be used in the output filenames. Be sure to be consistent with this as InterVar will use this too" }
  # InterVar
  annovar_db: { type: File, doc: "Annovar Database with at minimum required resources to InterVar" }
  annovar_db_str: { type: 'string?', doc: "Name of dir created when annovar db is un-tarred", default: "annovar_humandb_hg38_intervar" }
  annovar_protocol: { type: 'string?', doc: "csv string of databases within `annovar_db` cache to run",
    default: "refGene,esp6500siv2_all,1000g2015aug_all,avsnp147,dbnsfp42a,clinvar_20210501,gnomad_genome,dbscsnv11,rmsk,ensGene,knownGene" }
  annovar_operation: { type: 'string?', doc: "csv string of how to treat each listed protocol",
    default: "g,f,f,f,f,f,f,f,r,g,g" }
  annovar_nastring: { type: 'string?', doc: "character used to represent missing values", default: '.' }
  annovar_otherinfo: { type: 'boolean?', doc: "print out otherinfo (information after fifth column in queryfile)", default: true }
  annovar_threads: { type: 'int?', doc: "Num threads to use to process filter inputs", default: 8 }
  annovar_ram: { type: 'int?', doc: "Memory to run tool. Sometimes need more", default: 32}
  annovar_vcfinput: { type: 'boolean?', doc: "Annotate vcf and generate output file as vcf", default: false }
  bcftools_strip_info: {type: 'string?', doc: "csv string of columns to strip if\
      \ needed to avoid conflict/improve performance of a tool, i.e INFO/CSQ"}
  intervar_db: { type: File, doc: "InterVar Database from git repo + mim_genes.txt" }
  intervar_db_str: { type: 'string?', doc: "Name of dir created when intervar db is un-tarred", default: "intervardb" }
  intervar_ram: { type: 'int?', doc: "Min ram needed for task in GB", default: 32 }
  # autoPVS1
  autopvs1_db: { type: File, doc: "git repo files plus a user-provided fasta reference"}
  autopvs1_db_str: { type: 'string?', doc: "Name of dir created when annovar db is un-tarred", default: "data"}

outputs:
  intervar_classification: { type: File, outputSource: run_intervar/intervar_classification}
  autopvs1_tsv: { type: File, outputSource: run_autopvs1/autopvs1_tsv }
  annovar_vcfoutput: { type: 'File?', outputSource: run_intervar/annovar_vcfoutput}
  annovar_txt: { type: File, outputSource: run_intervar/annovar_txt }
steps:
  run_intervar:
    run: intervar_classification_wf.cwl
    in:
        input_vcf: vep_vcf
        annovar_db: annovar_db
        annovar_db_str: annovar_db_str
        buildver: buildver
        output_basename: output_basename
        annovar_protocol: annovar_protocol
        annovar_operation: annovar_operation
        annovar_nastring: annovar_nastring
        annovar_otherinfo: annovar_otherinfo
        annovar_threads: annovar_threads
        annovar_ram: annovar_ram
        annovar_vcfinput: annovar_vcfinput
        bcftools_strip_info: bcftools_strip_info
        intervar_db: intervar_db
        intervar_db_str: intervar_db_str
        intervar_ram: intervar_ram
    out: [intervar_classification, annovar_vcfoutput, annovar_txt]

  run_autopvs1:
    run: ../tools/autopvs1.cwl
    in:
        autopvs1_db: autopvs1_db
        autopvs1_db_str: autopvs1_db_str
        vep_vcf: vep_vcf
        genome_version:  buildver
        output_basename: output_basename
    out: [autopvs1_tsv]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2

"sbg:links":
- id: 'https://github.com/d3b-center/D3b-Pathogenicity-Preprocessing/releases/tag/v1.0.0'
  label: github-release
