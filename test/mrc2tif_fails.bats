#!/usr/bin/env bats


# 
# Load the helper functions in test_helper.bash 
# Note the .bash suffix is omitted intentionally
# 
load test_helper

#
# Test to run is denoted with at symbol test like below
# the string after is the test name and will be displayed
# when the test is run
#
# This test uses the command script under the bin/ directory
# to simulate a failed command to verify the workflow
# properly handles the failure
#
@test "Test where mrc2tif fails" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  mkdir -p "$THE_TMP/input/data"
  echo "mymrc" > "$THE_TMP/input/data/input.mrc"
  echo "hi=1" > "$THE_TMP/imod"

  echo "1,,error," > "$THE_TMP/bin/command.tasks"

  # Run kepler.sh
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -CWS_outputdir $THE_TMP -mrc "$THE_TMP/input" -imodSourceScript "$THE_TMP/data" -imodSourceScript "$THE_TMP/imod" -mrc2tifCmd "$THE_TMP/bin/command" $WF

  # Check exit code, kepler is always zero even if it fails
  # which is why we have a WORKFLOW.FAILED.txt file
  [ "$status" -eq 0 ]

  # will only see this if kepler fails
  echoArray "${lines[@]}"
  

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  # Will be output if anything below fails
  cat "$THE_TMP/$README_TXT"

  # Verify we got a WORKFLOW.FAILED.txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  echo "WORKFLOW FAILED"
  cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  echo ""

  [ "${lines[0]}" == "simple.error.message=Error running mrc2tif" ]
  [ "${lines[1]}" == "detailed.error.message=Non zero exit code (1) from $THE_TMP/bin/command -p $THE_TMP/input/data/input.mrc $THE_TMP/data/slice : error" ]


  # Verify we got a README.txt
  [ -s "$THE_TMP/$README_TXT" ]

  # Check we did not get hello world output
  run egrep "^hello world" "$THE_TMP/$README_TXT"
  [ "$status" -eq 1 ]

}
 
