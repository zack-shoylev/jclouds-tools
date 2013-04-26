#!/bin/bash

if [ "$#" -ne 4 ]
then
  echo "jclouds-live-test.sh [repo] [release] [user] [password]"
fi

REPO=$1
RELEASE=$2
USER=$3
PASSWORD=$4

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
CONFPATH=$SCRIPTPATH . "/../conf"
CONFPATH=$(readlink -f $CONFPATH)

cd $REPO
git checkout $RELEASE

nova_clean() {
  nova --no-cache list | grep $USER | awk '{print $2}' | xargs -n 1 nova delete	
}

swift_clean() {
  swift list | grep $USER | xargs -n 1 swift delete
}

TESTS[0]=providers,rackspace-cloudservers-us,cloudservers-us-rc,nova_clean
TESTS[1]=providers,rackspace-cloudservers-uk,cloudservers-uk-rc,nova_clean
TESTS[2]=apis,cloudfiles,cloudfiles-us-rc,swift_clean
TESTS[3]=providers,cloudfiles-us,cloudfiles-us-rc,swift_clean
TESTS[4]=providers,cloudfiles-uk,cloudfiles-uk-rc,swift_clean
TESTS[5]=apis,cloudloadbalancers,cloudservers-us-rc
TESTS[6]=providers,cloudloadbalancers-us,cloudservers-us-rc
TESTS[7]=providers,cloudloadbalancers-uk,cloudservers-us-rc
TESTS[8]=apis,cloudservers,cloudservers-us-rc,nova_clean
TESTS[9]=providers,cloudservers-us,cloudservers-us-rc,nova_clean
TESTS[10]=providers,cloudservers-uk,cloudservers-uk-rc,nova_clean
TESTS[11]=apis,rackspace-cloudidentity,cloudservers-us-rc

if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ''
fi

for TEST in "${TESTS[@]}"; do
  IFS=","
  set $TEST
  TYPE=$1
  TESTABLE=$2
  RC=$CONFPATH . "/" . $3 . ".conf"
  CLEAN=$4

  source ~/$RC
  echo $RELEASE $TYPE $TESTABLE $RAX_USERNAME $RAX_APIKEY $CLEAN

  cd $REPO/$TYPE/$TESTABLE/
  mvn -Dtest.$TESTABLE.identity=$RAX_USERNAME -Dtest.$TESTABLE.credential=$RAX_APIKEY -Plive clean install | tee ../../../jclouds.github.com/documentation/releasenotes/1.6.0/`basename $PWD`.txt
  cp ./target/surefire-reports/TestSuite.txt ../../../jclouds.github.com/documentation/releasenotes/1.6.0/`basename $PWD`-failures.txt

  $CLEAN
done

