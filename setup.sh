#!/bin/bash

# Setup script to configure shebang lines/Queuing system/modules 

real_path=$(realpath $0)
bin_dir=$(dirname ${real_path})

# ANSI colour codes for output highlighting
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOL='\033[0m'

# First gather some info on the installation...
perl=$(which perl)
echo -n "Enter path to perl: [${perl}] "
read user_perl

if [ ! -z ${user_perl} ]; then 
	perl=${user_perl}
fi

echo -n "If this software is to be run on a PBSpro cluster requiring job submission to a particular queue, enter the desired queue name (enter to skip): "
read pbsqueue
echo 

cores=$(grep -c ^processor /proc/cpuinfo)
echo -n "Enter number of parallel threads to use: [${cores}] "
read user_cores
echo

if [ "${user_cores}" != "" ]; then
	cores=${user_cores}
fi

# check to see if we are running on the ICL HPC CX1 cluster, in which case we
# will need to add necessary 'module' lines to the scripts
cx1=$(hostname --long|grep cx1)
if [ ! ${cx1} == "\n" ]; then
	echo "Configuring scripts for running on cx1 cluster"
	echo
fi

if [ ! -e ${perl} ]; 
then
	echo
	echo -e "${RED}Error${NOCOL}: ${perl} is not executable"
	exit 1
fi

# Install required perl modules...
# First check that local::lib is installed
eval ${perl} -Mlocal::lib 2>&1 >/dev/null
if [ $? != 0 ];
then
	echo
	echo -e "${RED}Error${NOCOL}: The perl local::lib module must be installed before running setup.sh..."
	exit 1
fi

# and then check for CPAN
eval ${perl} -MCPAN -e'print $CPAN::VERSION' 2>&1 >/dev/null
if [ $? != 0 ];
then
	echo
	echo -e "${RED}Error${NOCOL}: The perl CPAN module must be installed before running setup.sh..."
	exit 1
fi


# Install prerequisite non-core perl modules into lib directory within
# installation directory
mods=('App::cpanminus Archive::Zip' 'Digest::MD5::File' 'File::Find::Rule' 'LWP::UserAgent' 
	'Statistics::Descriptive' 'XML::XPath' 'XML::XPath::Parser') 

for mod in ${mods[@]}; do 
	echo Installing ${mod}...
	ret=$(perl -MCPAN -Mlocal::lib='./' -e "install (${mod})"  >/dev/null 2>&1) 
done

# Bioperl has an interactive installation which can be bypassed with cpanm
echo Installing Bio::Perl
${bin_dir}/bin/cpanm -l'./' -f Bio::Perl

echo
echo Updating scripts...

for file in $(ls src); do
	cp src/${file} bin/${file}
	sed -i "s|##PERL##|$perl|" bin/${file}
	sed -i "s/##THREADS##/${cores}/" bin/${file}
	
	if [ ! ${cx1} == "\n" ]; then
		sed -i 's/##CX1##//g' bin/${file}
	fi

	if [ ! -z "${pbsqueue}" ]; then
		sed -i "s/##PBSQ_ENABLE##//" bin/${file}
		sed -i "s/##PBSQ##/$pbsqueue/" bin/${file}
	fi
	chmod +x bin/${file}
done
