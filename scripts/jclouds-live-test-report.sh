#!/bin/bash

tests[0]="rackspace-cloudservers-us"
tests[1]="rackspace-cloudservers-uk"
tests[2]="cloudfiles"
tests[3]="cloudfiles-us"
tests[4]="cloudfiles-uk"
tests[5]="cloudloadbalancers"
tests[6]="cloudloadbalancers-us"
tests[7]="cloudloadbalancers-uk"
tests[8]="cloudservers"
tests[9]="cloudservers-us"
tests[10]="cloudservers-uk"

for test in "${tests[@]}" 
do
  echo "****************************** $test ******************************"
  egrep "BUILD FAILURE" ~/dev/everett-toews/jclouds.github.com/documentation/releasenotes/1.5.0/$test.txt
  egrep "Tests run: .*, Failures: .*, Errors: .*, Skipped: .*, Time elapsed: .* sec" ~/dev/everett-toews/jclouds.github.com/documentation/releasenotes/1.5.0/$test.txt
done
