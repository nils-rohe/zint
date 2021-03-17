#!/bin/sh
export LC_ALL=C

#this script generates a script in .code-intelligence/ci/ for every campaign config file in CAMPAIGN_DIRECTORY and adds a section to the .travis.xml file to run it

FUZZ_TARGET_DIRECTORY=fuzz_targets #directory to be searched for fuzz target source files (input location)
FUZZ_TARGET_CONFIG_DIRECTORY=fuzz_targets #directory in which the fuzz target configurations will be created (output location)
CAMPAIGN_DIRECTORY=campaigns #directory in which the fuzz campaign configurations will be created (output location)

PROJECT_NAME=SET_IN_SCRIPT_TEMPLATE

#copy the manually configured part of the travis config file to .travis.yml.
#Later an entry for every fuzz target will be appended at the file end.
cat travis_static.yml > ../.travis.yml

#iterate over all C++ files in the FUZZ_TARGET_DIRECTORY
for file in "$CAMPAIGN_DIRECTORY"/*.json; do

    #read the name of campaign from the config file
    test_name=$(jq -r '.displayName' $file)
    
    #generate a travis CI/CD script for every fuzz target
    #this script installs and runs the cictl command line tool to start and monitor the campaign
    echo "Generating ci/${test_name}.sh"
    sed "s.TARGET_NAME.${test_name}.g" cicd_script_template.sh > ci/${test_name}.sh
    
    #Append a entry to the .travis.yml file
    echo "Append entry for ${test_name} to .travis.yml"
    sed "s.TARGET_NAME.${test_name}.g" travis_snippet >> ../.travis.yml
done
echo "All config files generated."
