#!/bin/sh

set -x
errx() {
    echo $1
    exit 1
}

validate() {
    HOST=$(timeout 5 curl http://$LB:8000/cgi-bin/app.py 2>/dev/null| grep -A1 hostname|tail -n1)
    [ -z $HOST ] && errx "validate() curl error "
    if [ "$HOST_" == "" ]; then
	HOST_=$HOST
	validate
	return
    fi
    [ "$HOST" != "$HOST_" ] && return
    validate
    return
}

kubectl describe services web-app-deploy || errx "kubectl describe error"
LB=$(kubectl describe services web-app-deploy|grep 'LoadBalancer Ingress:'|sed 's/LoadBalancer Ingress:[[:space:]]*//g')
timeout 5 curl http://$LB:8000/cgi-bin/app.py || errx "curl error"
HOST_=''
validate
exit 0
