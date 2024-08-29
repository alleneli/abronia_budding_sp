#!/bin/bash

## To run this script you need the contents of the following folders in your working directory:
######### gatk-4.4.0.0, IGV_Linux_2.16.2, bwa, as well as the jar file picard.jar.

printf "indexing reference fasta\n"
./bwa index normalized_aurita_ref.fna
printf "reference indexed\n"



printf "initiating BWA MEM for forward and reverse reads (files in *.fastq.gz)\n"
for f in $(ls *.fastq.gz | sed -e 's/_R1.fastq.gz//' -e 's/_R2.fastq.gz//' | sort -u); \
do bwa mem normalized_aurita_ref.fna \
${f}_R1.fastq.gz ${f}_R2.fastq.gz \
| gzip -3 > ${f}.bam.gz; done
printf "forward and reverse reads combined and converted to bam\n"



printf "sorting bam files\n"
for file in *bam.gz; do
java -jar picard.jar SortSam \
-I $file \
-O $file.sort \
-VALIDATION_STRINGENCY LENIENT \
-SORT_ORDER coordinate \
-MAX_RECORDS_IN_RAM 500000 \
-CREATE_INDEX True; done
printf "bam files sorted\n"



printf "marking and removing duplicates within bam files\n"
for file in *bam.gz.sort; do
java -jar picard.jar MarkDuplicates \
-I $file \
--REMOVE_DUPLICATES true \
-O $file.dup \
-METRICS_FILE marked_dup_metrics.txt; done
printf "duplicates removed\n"



printf "creating reference dictionary (.dict) and index (.fai) of reference fasta needed by GATK\n"
java -jar gatk-package-4.4.0.0-local.jar CreateSequenceDictionary -R normalized_aurita_ref.fna -O normalized_aurita_ref.dict

samtools faidx normalized_aurita_ref.fna
printf "dict and .fai index created from reference fasta\n"

printf "Renaming files to make them pretty for readgroup names\n"
for file in *.bam.gz.sort.dup; do mv -- "$file" "${file%.bam.gz.sort.dup}_"; done
for file in *.bam.gz.sort.dup.idx; do mv -- "$file" "${file%.bam.gz.sort.dup.idx}_.idx"; done
printf "Now they are pretty\n"


printf "setting readgroup names of bam files\n"
for file in *_; do
java -jar gatk-package-4.4.0.0-local.jar AddOrReplaceReadGroups \
-I $file \
-O $file.RG \
-SORT_ORDER coordinate \
-RGID foo \
-RGLB bar \
-RGPL illumina \
-RGPU unit1 \
-RGSM $file \
-CREATE_INDEX True; done
printf "readgroup names set\n"



printf "Call Haplotypes from bam files to produce .g.vcf files\n"
for file in *_.RG; do
./gatk HaplotypeCaller \
-R normalized_aurita_ref.fna \
-I $file \
-ERC GVCF \
-O $file.g.vcf; done
printf "Haplotypes called\n"



printf "making list of .g.vcf files to combine into one file\n"
ls *.g.vcf > abr_gvcf.list
printf "list of .g.vcf files made\n"



printf "Combining .g.vcf files into one .g.vcf file\n"
./gatk CombineGVCFs \
-R normalized_aurita_ref.fna \
--variant abr_gvcf.list \
-O abronia_combine.g.vcf.gz
printf ".g.vcf files combined\n"



printf "Genotyping samples within combined .g.vcf file\n"
./gatk GenotypeGVCFs \
-R normalized_aurita_ref.fna \
-V abronia_combine.g.vcf.gz \
-O abronia_combine_genotyped.g.vcf.gz \
--include-non-variant-sites true \
--annotate-with-num-discovered-alleles true
printf ".g.vcf genotyped\n"



printf "Selecting variants of genotyped .g.vcf\n"
./gatk SelectVariants \
-R normalized_aurita_ref.fna \
-V abronia_combine_genotyped.g.vcf.gz \
-O abronia_combine_genotyped_SelVar.g.vcf.gz \
--exclude-non-variants true \
--exclude-filtered true \
--select-type-to-include SNP
printf "Variants selected\n"
printf "All done, open output file (abronia_combine_genotyped_SelVar.g.vcf.gz) with bash igv.sh)\n"
printf "(つ•_•)つ > ⌐■-■ > (つ▀¯▀)つ\n"







