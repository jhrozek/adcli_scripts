#!/bin/bash

# Creates a number of Active Directory users for testing in the form of
# base_name0001 to base_name$num_users

if [ $# -eq 0 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` options (-bncd)"
  exit 1
fi

while getopts "b:n:c:d:" Option
do
  case $Option in
    b     ) base_name=$OPTARG;;
    n     ) num_users=$OPTARG;;
    c     ) ccache=$OPTARG;;
    d     ) domain=$OPTARG;;
    *     ) echo "Unknown option";;
  esac
done

if [ ! $base_name ]; then
    echo "Please specify the user basename with -b"
    exit 1
fi

if [ ! $num_users ]; then
    echo "Please specify the number of users to create with -n"
    exit 1
fi

ccache=${ccache-$KRB5CCNAME}
if [ ! $ccache ]; then
    echo "Please specify the Kerberos ccache with -c or set the KRB5CCNAME variable"
    exit 1
fi

if [ ! $domain ]; then
    echo "Please specify the AD domain to create the users with"
    exit 1
fi

for i in $(seq 1 $num_users); do
    username=$(printf "%s%05d\n" $base_name $i)
    adcli create-user --login-ccache=$ccache --domain=$domain $username
    if [ $? -ne 0 ]; then
        echo "Creating user $username failed, exit"
        exit
    fi
    echo "Created user $username"
done
