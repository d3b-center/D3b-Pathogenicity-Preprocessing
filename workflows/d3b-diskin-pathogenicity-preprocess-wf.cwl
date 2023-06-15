cwlVersion: v1.2
class: Workflow
id: d3b-diskin-pathogenicity-preprocess-wf
label: Pathogenicity Preprocessing Workflow
doc: |-
  # Pathogenicity Preprocessing Workflow

  ## Prequisite
  It is recommended to have first run the [Kids First Germline Annotation Workflow](https://github.com/kids-first/kf-germline-workflow/blob/v0.4.4/docs/GERMLINE_SNV_ANNOT_README.md) first.

  ## Pathogenicity Preprocessing Workflow
  This workflow uses the prerequisite input to run the InterVar workflow and autoPVS1 tool.
  Recommended inputs:
   - `annovar_db`: Annovar Database with at minimum required resources to InterVar. Need to use [annovar download commands](https://annovar.openbioinformatics.org/en/latest/user-guide/download/) to get the following:
       ```
              annovar_humandb_hg38_intervar/
          ├── hg38_AFR.sites.2015_08.txt
          ├── hg38_AFR.sites.2015_08.txt.idx
          ├── hg38_ALL.sites.2015_08.txt
          ├── hg38_ALL.sites.2015_08.txt.idx
          ├── hg38_AMR.sites.2015_08.txt
          ├── hg38_AMR.sites.2015_08.txt.idx
          ├── hg38_EAS.sites.2015_08.txt
          ├── hg38_EAS.sites.2015_08.txt.idx
          ├── hg38_EUR.sites.2015_08.txt
          ├── hg38_EUR.sites.2015_08.txt.idx
          ├── hg38_SAS.sites.2015_08.txt
          ├── hg38_SAS.sites.2015_08.txt.idx
          ├── hg38_avsnp147.txt
          ├── hg38_avsnp147.txt.idx
          ├── hg38_clinvar_20210501.txt
          ├── hg38_clinvar_20210501.txt.idx
          ├── hg38_dbnsfp42a.txt
          ├── hg38_dbnsfp42a.txt.idx
          ├── hg38_dbscsnv11.txt
          ├── hg38_dbscsnv11.txt.idx
          ├── hg38_ensGene.txt
          ├── hg38_ensGeneMrna.fa
          ├── hg38_esp6500siv2_all.txt
          ├── hg38_esp6500siv2_all.txt.idx
          ├── hg38_gnomad_genome.txt
          ├── hg38_gnomad_genome.txt.idx
          ├── hg38_kgXref.txt
          ├── hg38_knownGene.txt
          ├── hg38_knownGeneMrna.fa
          ├── hg38_refGene.txt
          ├── hg38_refGeneMrna.fa
          ├── hg38_refGeneVersion.txt
          ├── hg38_rmsk.txt
          └── hg38_seq
              ├── annovar_downdb.log
              └── hg38.fa
      ```
   - `intervar_db`: InterVar Database from git repo + mim_genes.txt
   - `autopvs1_db`: git repo files plus a user-provided fasta reference. For hg38, recommend:
      ```
      data
          ├── Homo_sapiens_assembly38.fasta
          ├── Homo_sapiens_assembly38.fasta.fai
          ├── PVS1.level
          ├── clinvar_pathogenic_GRCh38.vcf
          ├── clinvar_trans_stats.tsv
          ├── exon_lof_popmax_hg38.bed
          ├── expert_curated_domains_hg38.bed
          ├── functional_domains_hg38.bed
          ├── hgnc.symbol.previous.tsv
          ├── mutational_hotspots_hg38.bed
          └── ncbiRefSeq_hg38.gpe
      ```
   - `annovar_db_str`: Name of dir created when `annovar_db` tar ball in decompressed. Default: `annovar_humandb_hg38_intervar`
   - `autopvs1_db_str`: Name of dir created when `autopvs1_db` tar ball in decompressed. Default: `data`
   - `intervar_db_str`: Name of dir created when `intervar_db_str` tar ball in decompressed. Default: `intervardb`
  #### **Note:** We used a gene symbol liftover tool to allow gene symbols searches from different gene models to be found, `PVS1.level` was augmented with additional entries in which a gene symbols from the original file has changed.
  The [update_gene_symbols.py](https://github.com/d3b-center/D3b-DGD-Collaboration/blob/v0.2.0/scripts/update_gene_symbols.py) tool was used to achieve this, with liftover source obtained from [here](https://ftp.ebi.ac.uk/pub/databases/genenames/hgnc/archive/monthly/tsv/hgnc_complete_set_2021-06-01.txt) to match gene symbols from default/recommended VEP annotation. Example command:
  ```sh
  python3 /Users/brownm28/Documents/git_repos/D3b-DGD-Collaboration/scripts/update_gene_symbols.py -g hgnc_complete_set_2021-06-01.txt -f PVS1.level -z GENE level -u GENE -o results --explode_records 2> old_new.log
  ```
  With `results` used to replace `PVS1.level` file. Recommend references for this workflow can be obtained [here](https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/files/#q?path=d3b_diskin_pathogenicity).
  ### InterVar Classification Workflow
  This workflow is a critical component in generating scoring metrics needed to classify pathogenicity of variants.
  Documentation for this can be found [here](docs/INTERVAR_WF.md)
  ### AutoPVS1
  An additional pathogenicity scoring tool, run on the VEP-annotated input.
  Documentation for this can be found [here](autopvs1/README.md)
requirements:
- class: SubworkflowFeatureRequirement
inputs:
  # Common
  vep_vcf: {type: File, secondaryFiles: [.tbi], doc: "VCF file (with associated index)\
      \ to be annotated"}
  buildver: {type: ['null', {type: enum, symbols: ["hg38", "hg19", "hg18"], name: "buildver"}],
    doc: "Genome reference build version", default: "hg38"}
  output_basename: {type: string, doc: "String that will be used in the output filenames.\
      \ Be sure to be consistent with this as InterVar will use this too"}
  annovar_db: {type: File, doc: "Annovar Database with at minimum required resources\
      \ to InterVar", sbg:suggestedValue: {class: File, path: 648b2bf575423d2473af6ed8,
      name: annovar_humandb_hg38_intervar.tgz}}
  annovar_db_str: {type: 'string?', doc: "Name of dir created when annovar db is un-tarred",
    default: "annovar_humandb_hg38_intervar"}
  annovar_protocol: {type: 'string?', doc: "csv string of databases within `annovar_db`\
      \ cache to run", default: "refGene,esp6500siv2_all,1000g2015aug_all,avsnp147,dbnsfp42a,clinvar_20210501,gnomad_genome,dbscsnv11,rmsk,ensGene,knownGene"}
  annovar_operation: {type: 'string?', doc: "csv string of how to treat each listed\
      \ protocol", default: "g,f,f,f,f,f,f,f,r,g,g"}
  annovar_nastring: {type: 'string?', doc: "character used to represent missing values",
    default: '.'}
  annovar_otherinfo: {type: 'boolean?', doc: "print out otherinfo (information after\
      \ fifth column in queryfile)", default: true}
  annovar_threads: {type: 'int?', doc: "Num threads to use to process filter inputs",
    default: 8}
  annovar_ram: {type: 'int?', doc: "Memory to run tool. Sometimes need more", default: 32}
  annovar_vcfinput: {type: 'boolean?', doc: "Annotate vcf and generate output file\
      \ as vcf", default: false}
  bcftools_strip_info: {type: 'string?', doc: "csv string of columns to strip if needed\
      \ to avoid conflict/improve performance of a tool, i.e INFO/CSQ", default: "^INFO/DP"}
  intervar_db: {type: File, doc: "InterVar Database from git repo + mim_genes.txt",
    sbg:suggestedValue: {class: File, path: 648b2bf575423d2473af6ed6, name: intervardb_2021-08.tar.gz}}
  intervar_db_str: {type: 'string?', doc: "Name of dir created when intervar db is\
      \ un-tarred", default: "intervardb"}
  intervar_ram: {type: 'int?', doc: "Min ram needed for task in GB", default: 32}
  autopvs1_db: {type: File, doc: "git repo files plus a user-provided fasta reference",
    sbg:suggestedValue: {class: File, path: 648b2bf575423d2473af6ed7, name: autoPVS1_references_sym_updated.tar.gz}}
  autopvs1_db_str: {type: 'string?', doc: "Name of dir created when annovar db is\
      \ un-tarred", default: "data"}
outputs:
  intervar_classification: {type: File, outputSource: run_intervar/intervar_classification}
  autopvs1_tsv: {type: File, outputSource: run_autopvs1/autopvs1_tsv}
  annovar_vcfoutput: {type: 'File?', outputSource: run_intervar/annovar_vcfoutput}
  annovar_txt: {type: File, outputSource: run_intervar/annovar_txt}
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
      genome_version: buildver
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
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
