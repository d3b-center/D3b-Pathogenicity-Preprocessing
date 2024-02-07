"""
A script to create a suitable ClinVar reference vcf that:
 - Removes contigs that are not in your fasta
 - Uses chr contig nomenclature
 - Uses a variants_summary file to break up N alts to usage ACGT alleles
"""

import pysam
import argparse
import json
import pdb


def split_records(record, nt_list, out):
    for nt in nt_list:
        record.alts = nt
        out.write(record)

def create_mod_vcf(output_path, input_path, threads, nt_json, contig_skip_list):
    nt_dict  = json.load(nt_json)
    input_vcf = pysam.VariantFile(input_path, 'r', threads=threads)
    output = pysam.VariantFile(output_path, 'w', header=input_vcf.header)
    for record in input_vcf.fetch():
        pdb.set_trace()
        if record.contig not in (contig_skip_list):
            if record.contig == "MT":
                record.contig = "chrM"
            else:
                record.contig = "chr" + record.contig
            if record.alts in nt_dict:
                split_records(record, nt_dict[record.alts], output)
            else:
                output.write(record)

def main():
    parser = argparse.ArgumentParser(
            description = 'Modify ClinVar VCF for better suitability as a reference')

    parser.add_argument('--input_vcf', 
            help='ClinVar vcf to modify')
    parser.add_argument('--nt_json',
            help='json with IUPAC nt symbols for non-ACGT alleles')
    parser.add_argument('--contig_skip_csv',
            help='csv string of contigs to skip')
    parser.add_argument('--output_filename',
            help='String to use as name for output file [e.g.] task ID')
    parser.add_argument('--threads',
            help='Num threads to use for read/write', default=1)

    args = parser.parse_args()

    output_vcf_name = args.output_filename

    # Create and index the modified VCF
    create_mod_vcf(output_vcf_name, args.input_vcf, int(args.threads), args.nt_json, args.contig_skip_csv.split(','))
    pysam.tabix_index(output_vcf_name, preset="vcf", force=True)


if __name__ == '__main__':
    main()
