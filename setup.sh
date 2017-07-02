#!/bin/bash

# Setup script to configure shebang lines/Queuing system/modules 

# Replace __PERL__ placeholder in shebang lines with either the default system
# perl or user-defined perl binary

# ANSI colour codes for output highlighting
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOL='\033[0m' 

perl=$(which perl)
echo -n "Enter path to perl: [${perl}] "
read user_perl

if [ ! -z ${user_perl} ]; 
then 
	perl=${user_perl}
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
mods=('Archive::Zip' 'Digest::MD5::File' 'LWP::UserAgent' 'XML::XPath'
	'XML::XPath::Parser') 
for mod in ${mods[@]}; do 
	echo Installing ${mod}...
	ret=$(perl -MCPAN -Mlocal::lib='./' -e "install(${mod})"  >/dev/null 2>&1) 
done

# rewrite files from src directory into bin via seddage...
#sed -i s/__PERL__/${perl}/ bin/*
