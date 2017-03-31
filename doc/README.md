*Caroline Colijn TB variable site alignment pipeline

A pipeline is required to align sequence reads from many TB isolates against a reference strain,identify SNVs and small indels while ignoring hyper-variable regions and produce a variable-site alignment along with an index to relate each locus to the genomic location 

Initial data analysis is to be carried out on the publically available data referred to in Drobniewski et al (2016) doi:10.1371/journal.pmed.1002137, for which the data is available from the ENA Project ERP0003508

Fastq files for 415 samples were downloaded using bin/download_era_project, and saved in 'reads'. Note the paper refers to sequencing of 344 isolates...

There seems to be a lookup of samples ->strains -> runs available at http://www.sanger.ac.uk/resources/downloads/bacteria/mycobacterium.html#project_2688, saved here as doc/sample_ids.txt

First analysis run carried out using tagged version 0.1.1:
/groupvol/med-bio/jamesa/colijn/tb_pipeline/bin/submit_tb_run -i /groupvol/med-bio/jamesa/colijn/reads/ERP003508/ -o /groupvol/med-bio/jamesa/colijn/analysis/ERP003508 -r /groupvol/med-bio/jamesa/colijn/reference_data/AL123456.fasta
