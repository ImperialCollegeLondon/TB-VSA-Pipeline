# TB Variable Site Alignment Pipeline

This pipeline has been produced to generate variable-site alignments
(consisting solely of SNVs) specifically for Mycobacterium tuberculosis, on
behalf of Caroline Colijn, Dept. of Mathematics, Imperial College London. 

It may well be applicable to other organisms but some modification may be
required to variant calling/filtering according to the genome in question.

It is designed to be run on a cluster running the PBSPro scheduling software,
but can also be run directly without the use of a queueing system. Running
under a different queuing system will require modification of the 'submit_*'
scripts.

## Installation

To install the latest version: 

git clone https://github.com/ImperialCollegeLondon/TB-VSA-Pipeline
cd TB-VSA-Pipeline
./setup.sh

See TB_pipeline.pdf in doc/ for full details on installation
