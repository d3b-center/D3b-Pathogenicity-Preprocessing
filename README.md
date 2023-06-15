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