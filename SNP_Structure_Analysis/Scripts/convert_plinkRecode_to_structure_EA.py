#Run like python plink_to_structure_input.py *recode.strct_in name_table.csv
import re,sys,os

outputfile=sys.argv[1]+".structure_input_formatted.str"


#Step 1 is to  remove the first 2 rows of the file for file processing but retain them if needed later
linecounter=0
taxadict={}
with open(sys.argv[1],"r") as plink:
	for line in plink:
		if linecounter ==0:
			line_number_one=line
			linecounter+=1
		elif linecounter ==1:
			line_number_two=line
			linecounter+=1	
		else:#Writing all the lines 3 and onward to a temp file
			with open("temp1","a+") as temp1:
				temp1.write(line)
		taxa=line.split(" ")[0]
		taxadict[taxa]="1"# This will be used to default all a priori population designations to 1 

#Step 2 is to change all the populations to 1 if not specified in sys.arg[2], or else change them to those specified in that table. Also determine the number of columns in the dataset
if len(sys.argv) == 3:
	print ("Assigning population labels according to those specified in",sys.argv[2])
	with open(sys.argv[2],"r") as labeltable:
		for line in labeltable:
			splits=line.strip().split(",")
			taxadict[splits[0]]=splits[1] # Updating the dict with population designations provided in a comma seperated value table

	with open("temp1","r") as step1:
		for line in step1:
			splits=line.split(" ")
			num_columns=len(splits)#Identifying how many columns there are in the dataset
			taxa=splits[0]		
			#~ print taxadict[taxa] 
		
			#Replacing the population label in the file and saving to temp2
			splits[1]=taxadict[taxa] 
			print (splits[1])
			newline=" ".join(splits)
			
			with open("temp2","a+") as temp2:
				temp2.write(newline)
			
elif len(sys.argv) == 2:
	print ("Defaulting to specifying '1' for all taxa populations")
	with open("temp1","r") as step1:
		for line in step1:
			splits=line.split(" ")
			num_columns=len(splits)#Identifying how many columns there are in the dataset
			taxa=splits[0]
				
			#Replacing the population label in the file and saving to temp2
			splits[1]=taxadict[taxa] 
			print (splits[1])
			newline=" ".join(splits)
			
			with open("temp2","a+") as temp2:
				temp2.write(newline)


#Step 3 is to change all the 0s (missing data) into -9 (or whatever else you want).
with open("temp2","r") as t3:
	with open("temp4","w+") as out:
		for line in t3:
			splits=line.strip().split(" ")
			taxon_and_pop=splits[0:2]
			print ("Reformatting 0s to -9s for",taxon_and_pop)
			data=splits[2:]
			convertedData=[]
			for item in data:
				if str(item)=="0":
					convertedData+=["-9"]
				else:
					convertedData+=[item]
				
			joined="\t".join(taxon_and_pop+convertedData)
			out.write(joined+"\n")
			
#Step 4 is to finish formating things as needed and save all the data to the final file.
with open("temp4","r") as In:
	with open(outputfile,"w+") as out:
		for line in In:
			out.write(line)


#Cleaning up
os.remove("temp1")
os.remove("temp2")
#os.remove("temp3")
os.remove("temp4")
