#!/bin/bash

# Add existing group members to AD groups. Adds one group member to the first
# group, two members to second group and so on until the script reaches
# num_objects. The resulting group structure looks like this:
#       basegroup0001: baseuser0001
#       basegroup0002: baseuser0001, baseuser0002, ...

if [ $# -eq 0 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` options (-guncd)"
  exit 1
fi

while getopts "g:u:n:c:d:" Option
do
  case $Option in
    g     ) base_group_name=$OPTARG;;
    u     ) base_user_name=$OPTARG;;
    n     ) num_objects=$OPTARG;;
    c     ) ccache=$OPTARG;;
    d     ) domain=$OPTARG;;
    *     ) echo "Unknown option";;
  esac
done

if [ ! $base_group_name ]; then
    echo "Please specify the group basename with -g"
    exit 1
fi

if [ ! $base_user_name ]; then
    echo "Please specify the group basename with -u"
    exit 1
fi

if [ ! $num_objects ]; then
    echo "Please specify the number of objects to add members to"
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

for i in $(seq 1 $num_objects); do
    groupname=$(printf "%s%05d\n" $base_group_name $i)
    for ii in $(seq 1 $i); do
        username=$(printf "%s%05d\n" $base_user_name $ii)
        adcli add-member --login-ccache=$ccache --domain=$domain $groupname $username
        if [ $? -ne 0 ]; then
            echo "Adding $username to $groupname failed, exit"
            exit
        fi
        echo "Added $username to $groupname"
    done
done
