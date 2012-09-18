#!/bin/bash

if [ ! -z "$1" ]; then
  RELEASE=$1
  cd ~/dev/everett-toews/jclouds/
  git checkout $RELEASE
fi

nova_clean() {
  nova --no-cache list | grep $USER | awk '{print $2}' | xargs -n 1 nova delete	
}

swift_clean() {
  swift list | grep $USER | xargs -n 1 swift delete
}

TESTS[0]=providers,rackspace-cloudservers-us,.cloudservers-us-rc,nova_clean
TESTS[1]=providers,rackspace-cloudservers-uk,.cloudservers-uk-rc,nova_clean
TESTS[2]=apis,cloudfiles,swift_clean
TESTS[3]=providers,cloudfiles-us,swift_clean
TESTS[4]=providers,cloudfiles-uk,swift_clean
TESTS[5]=apis,cloudloadbalancers,.cloudservers-us-rc
TESTS[6]=providers,cloudloadbalancers-us,.cloudservers-us-rc
TESTS[7]=providers,cloudloadbalancers-uk,.cloudservers-us-rc
TESTS[8]=apis,cloudservers,.cloudservers-us-rc,nova_clean
TESTS[9]=providers,cloudservers-us,.cloudservers-us-rc,nova_clean
TESTS[10]=providers,cloudservers-uk,.cloudservers-uk-rc,nova_clean
TESTS[11]=apis,rackspace-cloudidentity,.cloudservers-us-rc

if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ''
fi

for TEST in "${TESTS[@]}"; do
  IFS=","
  set $TEST
  TYPE=$1
  TESTABLE=$2
  RC=$3
  CLEAN=$4

  source ~/$RC
  echo $RELEASE $TYPE $TESTABLE $OS_USERNAME $OS_APIKEY $CLEAN

  cd ~/dev/everett-toews/jclouds/$TYPE/$TESTABLE/
  mvn -Dtest.$TESTABLE.identity=$OS_USERNAME -Dtest.$TESTABLE.credential=$OS_APIKEY -Plive clean install | tee ../../../jclouds.github.com/documentation/releasenotes/1.5.0/`basename $PWD`.txt
  cp ./target/surefire-reports/TestSuite.txt ../../../jclouds.github.com/documentation/releasenotes/1.5.0/`basename $PWD`-failures.txt

  $CLEAN
done

