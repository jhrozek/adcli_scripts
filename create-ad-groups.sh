#!/bin/bash

# Creates a number of Active Directory groups for testing in the form of
# base_name0001 to base_name$num_groups

if [ $# -eq 0 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` options (-bncd)"
  exit 1
fi

while getopts "b:n:c:d:" Option
do
  case $Option in
    b     ) base_name=$OPTARG;;
    n     ) num_groups=$OPTARG;;
    c     ) ccache=$OPTARG;;
    d     ) domain=$OPTARG;;
    *     ) echo "Unknown option";;
  esac
done

if [ ! $base_name ]; then
    echo "Please specify the group basename with -b"
    exit 1
fi

if [ ! $num_groups ]; then
    echo "Please specify the number of groups to create with -n"
    exit 1
fi

ccache=${ccache-$KRB5CCNAME}
if [ ! $ccache ]; then
    echo "Please specify the Kerberos ccache with -c or set the KRB5CCNAME variable"
    exit 1
fi

if [ ! $domain ]; then
    echo "Please specify the AD domain to create the groups with"
    exit 1
fi

for i in $(seq 1 $num_groups); do
    groupname=$(printf "%s%05d\n" $base_name $i)
    adcli create-group --login-ccache=$ccache --domain=$domain $groupname
    if [ $? -ne 0 ]; then
        echo "Creating group $groupname failed, exit"
        exit
    fi
    echo "Created group $groupname"
done
