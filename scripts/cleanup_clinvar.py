"""
A script to create a suitable ClinVar reference vcf that:
 - Removes contigs that are not in your fasta
 - Uses chr contig nomenclature
 - Uses a variants_summary file to break up N alts to usage ACGT alleles
"""

import pysam
import argparse
import json
import gzip
import pdb


def split_records(record, nt_list, out):
    for nt in nt_list:
        record.alts = (nt,)
        out.write(record)


def update_contig_header(contig_list, header):
    for contig in contig_list:
        header.contigs.add(contig)


def create_mod_vcf(output_path, input_path, threads, update_dict, non_canon_dict, var_sum_path, update_path):
    input_vcf = pysam.VariantFile(input_path, 'r', threads=threads)
    # add new contigs to header
    update_contig_header(update_dict['renamed_contigs'], input_vcf.header)
    # add program command for pizzaz
    input_vcf.header.add_meta("cleanup_clinvar.py", "--input_vcf {} --variant_summary {} --update_json {} --output_filename {} --threads {}".format(input_path, var_sum_path, update_path, output_path, threads))

    output = pysam.VariantFile(output_path, 'w', header=input_vcf.header)
    cur = ""
    rename = ""
    for record in input_vcf.fetch():
        try:
            if record.contig in update_dict['old_contigs']:
                if record.contig != cur:
                    cur = record.contig
                    if cur in update_dict['old_contigs']:
                        rename = update_dict['renamed_contigs'][update_dict['old_contigs'].index(cur)]
                record.contig = rename
                # Use variant id in non-canon dict to update alts
                if record.id in non_canon_dict:
                    update_alts = update_dict['iupac'][non_canon_dict[record.id]]
                    split_records(record, update_alts, output)
                else:
                    output.write(record)
        except Exception as e:
            print(e)
            pdb.set_trace()


def get_non_canon(var_sum_fn, update_dict):
    with (gzip.open if var_sum_fn.endswith(".gz") else open)(var_sum_fn, "rt", encoding="utf-8") as var_sum:
        non_canon_dict = {}
        head = next(var_sum)
        header = head.rstrip('\n').split('\t')
        v_idx = header.index('VariationID')
        a_idx = header.index('AlternateAlleleVCF')
        for entry in var_sum:
            info = entry.rstrip('\n').split('\t')
            if info[a_idx] in update_dict['iupac']:
                non_canon_dict[info[v_idx]] = info[a_idx]
        return non_canon_dict


def main():
    parser = argparse.ArgumentParser(
            description = 'Modify ClinVar VCF for better suitability as a reference')

    parser.add_argument('--input_vcf', 
            help='ClinVar vcf to modify')
    parser.add_argument('--variant_summary', 
            help='ClinVar variant summary file')
    parser.add_argument('--update_json',
            help='json with IUPAC nt symbols for non-ACGT alleles')
    parser.add_argument('--output_filename',
            help='String to use as name for output file')
    parser.add_argument('--threads',
            help='Num threads to use for read/write', default=1)

    args = parser.parse_args()

    output_vcf_name = args.output_filename
    update_dict  = json.load(open(args.update_json))
    # Get variants with non-ACGT alts, index by variation id
    non_canon_dict = get_non_canon(args.variant_summary, update_dict)        
    # Create and index the modified VCF
    create_mod_vcf(output_vcf_name, args.input_vcf, int(args.threads), update_dict, non_canon_dict, args.variant_summary, args.update_json)
    pysam.tabix_index(output_vcf_name, preset="vcf", force=True)


if __name__ == '__main__':
    main()
