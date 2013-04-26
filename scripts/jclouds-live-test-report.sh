#!/bin/bash

tests[0]="cloudfiles-uk"
tests[1]="cloudfiles-us"
tests[2]="cloudloadbalancers-uk"
tests[3]="cloudloadbalancers-us"
tests[4]="cloudservers-uk"
tests[5]="cloudservers-us"
tests[6]="rackspace-cloudservers-uk"
tests[7]="rackspace-cloudservers-us"
tests[8]="cloudfiles"
tests[9]="cloudloadbalancers"
tests[10]="cloudservers"
tests[11]="rackspace-cloudidentity"

for test in "${tests[@]}" 
do
  echo "****************************** $test ******************************"
  egrep "BUILD FAILURE" ~/dev/everett-toews/jclouds.github.com/documentation/releasenotes/1.6.0/$test.txt
  egrep "Tests run: .*, Failures: .*, Errors: .*, Skipped: .*, Time elapsed: .* sec" ~/dev/everett-toews/jclouds.github.com/documentation/releasenotes/1.5.0/$test.txt
done
