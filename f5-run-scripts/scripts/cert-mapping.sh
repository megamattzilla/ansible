#!/bin/bash
# Search /config and sub directories (partitions) for bigip.conf files
LIST=`find /config -name bigip.conf |  xargs  awk '$2 == "virtual" {print $3}' 2> /dev/null | sort -u`
echo "Virtual:          Profile:        Certificate:          Ciphers:          Expiration:          Expiration Epoch:"
echo "__________________________________________________________"
for VAL in ${LIST}
do
PROF=`tmsh show /ltm virtual ${VAL} profiles 2> /dev/null | grep -B 1 " Ltm::ClientSSL Profile:" | cut -d: -f4 | grep -i "[a-z]" | sed s'/ //'g| sort -u`
test -n "${PROF}" 2>&- && {
VIRTS=`expr $VIRTS + 1`
for PCRT in ${PROF}
do
CERT=`tmsh list /ltm profile client-ssl ${PCRT} |  awk '$1 == "cert" {print $2}' 2> /dev/null | sort -u`
test -n "${CERT}" 2>&- && {
CIPHERS=`tmsh list /ltm profile client-ssl ${PCRT} ciphers | grep ciphers | awk '{print $2}'`
EXDATE=`tmsh list /sys file ssl-cert ${CERT} | grep expiration-string | awk -F '"' '{print $2}'`
EXDATEEPOCH=`tmsh list /sys file ssl-cert ${CERT} | grep expiration-date | awk '{print $2}'`
echo "${VAL} ${PCRT} ${CERT} ${CIPHERS} ${EXDATE} ${EXDATEEPOCH}"
}
done
}
done
echo "Virtual server count: ${VIRTS}"