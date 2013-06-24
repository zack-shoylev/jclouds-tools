#!/bin/bash

if [ ! -z "$1" ]; then
  RELEASE=$1
  cd ~/jclouds/
  git fetch
  git checkout --track $RELEASE
  git pull --rebase
fi

nova_clean() {
  nova --no-cache list | grep $USER | awk '{print $2}' | xargs -n 1 nova delete	
}

swift_clean() {
  swift list | grep $USER | xargs -n 1 swift delete
}

TESTS[0]=providers,rackspace-cloudservers-uk,.cloudservers-uk-rc,nova_clean
TESTS[1]=apis,cloudfiles,.cloudfiles-uk-rc,swift_clean
TESTS[2]=providers,cloudfiles-uk,.cloudfiles-uk-rc,swift_clean
TESTS[3]=apis,cloudloadbalancers,.cloudservers-uk-rc
TESTS[4]=providers,cloudloadbalancers-uk,.cloudservers-uk-rc
TESTS[5]=apis,cloudservers,.cloudservers-uk-rc,nova_clean
TESTS[6]=providers,cloudservers-uk,.cloudservers-uk-rc,nova_clean
TESTS[7]=apis,rackspace-cloudidentity,.cloudservers-uk-rc

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
  echo "Variables:"
  echo $RELEASE $TYPE $TESTABLE $RAX_USERNAME $RAX_APIKEY $CLEAN

  cd ~/jclouds/$TYPE/$TESTABLE/
  echo mvn -Dtest.$TESTABLE.identity=$RAX_USERNAME -Dtest.$TESTABLE.credential=$RAX_APIKEY -Plive clean install
  mvn -Dtest.$TESTABLE.identity=$RAX_USERNAME -Dtest.$TESTABLE.credential=$RAX_APIKEY -Plive clean install | tee ~/jclouds.github.com/documentation/releasenotes/1.6.0/`basename $PWD`.txt
  cp ./target/surefire-reports/TestSuite.txt ~/jclouds.github.com/documentation/releasenotes/1.6.0/`basename $PWD`-failures.txt

  $CLEAN
done

