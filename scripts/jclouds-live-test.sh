#!/bin/bash

nova-clean() {
  nova list | grep $USER | awk '{print $2}' | xargs -n 1 nova delete	
}

swift-clean() {
  swift list | grep $USER | xargs -n 1 swift delete
}

TESTS[0]=providers,rackspace-cloudservers-us,.cloudservers-us-rc,nova-clean
TESTS[1]=providers,rackspace-cloudservers-uk,.cloudservers-us-rc,nova-clean
TESTS[2]=apis,cloudfiles,swift-clean
TESTS[3]=providers,cloudfiles-us,swift-clean
TESTS[4]=providers,cloudfiles-uk,swift-clean
TESTS[5]=apis,cloudloadbalancers,.cloudservers-us-rc
TESTS[6]=providers,cloudloadbalancers-us,.cloudservers-us-rc
TESTS[7]=providers,cloudloadbalancers-uk,.cloudservers-us-rc
TESTS[8]=apis,cloudservers,.cloudservers-us-rc,nova-clean
TESTS[9]=providers,cloudservers-us,.cloudservers-us-rc,nova-clean
TESTS[10]=providers,cloudservers-uk,.cloudservers-us-rc,nova-clean

for TEST in "${TESTS[@]}"; do
  IFS=","
  set $TEST
  TYPE=$1
  TESTABLE=$2
  RC=$3
  CLEAN=$4

  source ~/$RC
  echo $TYPE $TESTABLE $OS_USERNAME $OS_APIKEY $CLEAN

  cd ~/dev/everett-toews/jclouds/$TYPE/$TESTABLE/
  mvn -Dtest.$TESTABLE.identity=$OS_USERNAME -Dtest.$TESTABLE.credential=$OS_APIKEY -Plive clean install | tee ../../../jclouds.github.com/documentation/releasenotes/1.5.0/`basename $PWD`.txt
  cp ./target/surefire-reports/TestSuite.txt ../../../jclouds.github.com/documentation/releasenotes/1.5.0/`basename $PWD`-failures.txt

  $CLEAN
done

