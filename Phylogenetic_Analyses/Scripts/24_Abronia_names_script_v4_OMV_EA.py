#!/usr/bin/python

#Program to change the name of tips in trees and files
#so codes are changed for species names
#Made by Oscar Vargas, modified by Eli Allen

import glob
import argparse

####### Arguments and help ###########
parser = argparse.ArgumentParser(description="\
Script change codes to names in files based on dictiory hardcoded in this script \
written by Oscar Vargas oscarmvargas.com\
")
parser.add_argument("-i", "--input", help="input file/s ending pattern, required", type=str, required = True)
parser.add_argument("-o", "--output_suffix", help="suffix to be added to output file", type=str, default=".rn4")
parser.parse_args()
args = parser.parse_args()

file_suffix = args.input
output_suffix = args.output_suffix
######################################

files = glob.glob("*" + file_suffix)

replacements = {'A_cf_EEA0074':'Abronia_villosa_×_umbellata_EEA0074','A_cf_EEA0075':'Abronia_villosa_×_umbellata_EEA0075','A_umb_brev_EEA0108':'Abronia_umbellata_var._breviflora_EEA0108','A_umb_brev_EEA109':'Abronia_umbellata_var._breviflora_EEA0109','A_umb_brev_EFL30':'Abronia_umbellata_var._breviflora_EFL0030','A_umb_umb_EEA0012':'Abronia_umbellata_var._umbellata_EEA0012','A_umb_umb_EEA0070':'Abronia_umbellata_var._umbellata_EEA0070','A_umb_umb_EEA0071':'Abronia_umbellata_var._umbellata_EEA0071','A_umb_umb_EEA0072':'Abronia_umbellata_var._umbellata_EEA0072','A_umb_umb_EEA0073':'Abronia_umbellata_var._umbellata_EEA0073','A_umb_umb_EEA0076':'Abronia_umbellata_var._umbellata_EEA0076','A_umb_umb_EEA0078':'Abronia_umbellata_var._umbellata_EEA0078','A_umb_umb_EEA0106':'Abronia_umbellata_var._umbellata_EEA0106','A_umb_umb_EEA0107':'Abronia_umbellata_var._umbellata_EEA0107','A_umb_umb_EEA0115':'Abronia_umbellata_var._umbellata_EEA0115','A_umb_umb_EEA0116':'Abronia_umbellata_var._umbellata_EEA0116','A_umb_umb_EEA79':'Abronia_umbellata_var._umbellata_EEA0079','A_umb_umb_LAG559':'Abronia_umbellata_var._umbellata_LAG0559','A_vil_aur_EEA0021':'Abronia_villosa_var._aurita_EEA0021','A_vil_aur_EEA0023':'Abronia_villosa_var._aurita_EEA0023','A_vil_aur_EEA0080':'Abronia_villosa_var._aurita_EEA0080','A_vil_aur_EEA0081':'Abronia_villosa_var._aurita_EEA0081','A_vil_aur_EEA0082':'Abronia_villosa_var._aurita_EEA0082','A_vil_aur_EEA0083':'Abronia_villosa_var._aurita_EEA0083','A_vil_aur_EEA0085':'Abronia_villosa_var._aurita_EEA0085','A_vil_aur_EEA0086':'Abronia_villosa_var._aurita_EEA0086','A_vil_aur_EEA0087':'Abronia_villosa_var._aurita_EEA0087','A_vil_aur_EEA0088':'Abronia_villosa_var._aurita_EEA0088','A_vil_aur_EEA0093':'Abronia_villosa_var._aurita_EEA0093','A_vil_aur_EEA0094':'Abronia_villosa_var._aurita_EEA0094','A_vil_aur_EEA0095':'Abronia_villosa_var._aurita_EEA0095','A_vil_aur_EEA0096':'Abronia_villosa_var._aurita_EEA0096','A_vil_aur_EEA0101':'Abronia_villosa_var._aurita_EEA0101','A_vil_aur_EEA0103':'Abronia_villosa_var._aurita_EEA0103','A_vil_aur_EEA0104':'Abronia_villosa_var._aurita_EEA0104','A_vil_aur_EEA0105':'Abronia_villosa_var._aurita_EEA0105','A_vil_aur_EEA102':'Abronia_villosa_var._aurita_EEA0102','A_vil_aur_EEA97':'Abronia_villosa_var._aurita_EEA0097','A_vil_aur_EEA98':'Abronia_villosa_var._aurita_EEA0098','A_vil_aur_LAG556':'Abronia_villosa_var._aurita_LAG0556','A_vil_vil_EEA0025':'Abronia_villosa_var._villosa_EEA0025','A_vil_vil_EEA0026':'Abronia_villosa_var._villosa_EEA0026','A_vil_vil_EEA0027':'Abronia_villosa_var._villosa_EEA0027','A_vil_vil_EEA0035':'Abronia_villosa_var._villosa_EEA0035','A_vil_vil_EEA0089':'Abronia_villosa_var._villosa_EEA0089','A_vil_vil_EEA0099':'Abronia_villosa_var._villosa_EEA0099','A_vil_vil_EEA110':'Abronia_villosa_var._villosa_EEA0110','A_vil_vil_EEA111':'Abronia_villosa_var._villosa_EEA0111','A_gra_EEA0054':'Abronia_gracilis_EEA0054','A_gra_EEA0117':'Abronia_gracilis_EEA0117','A_lat_EEA0113':'Abronia_latifolia_EEA0113'}

for file in files:
	print ('working on ' + file)
	lines = []        
	with open(file) as infile:
	    for line in infile:
	        for src, target in replacements.items():
	            line = line.replace(src, target)
	        lines.append(line)
	outfile = file + output_suffix
	with open(outfile, 'w') as outfile:
	    for line in lines:
        	outfile.write(line)

