#!/bin/sh
export LC_ALL=C

#this script generates a fuzz target config file in FUZZ_TARGET_CONFIG_DIRECTORY and a campaign config file in CAMPAIGN_DIRECTORY
#for each *.cpp file in the FUZZ_TARGET_DIRECTORY. 
#. To update build flags just change them in the template and (re-)run this script

FUZZ_TARGET_DIRECTORY=fuzz_targets #directory to be searched for fuzz target source files (input location)
FUZZ_TARGET_CONFIG_DIRECTORY=fuzz_targets #directory in which the fuzz target configurations will be created (output location)
CAMPAIGN_DIRECTORY=campaigns #directory in which the fuzz campaign configurations will be created (output location)

PROJECT_NAME=NOT_USED

#copy the manually configured part of the travis config file to .travis.yml.
#Later an entry for every fuzz target will be appended at the file end.
cat travis_static.yml > .travis.yml

#iterate over all C++ files in the FUZZ_TARGET_DIRECTORY
for file in "$CAMPAIGN_DIRECTORY"/*.json; do

    file_name=${file##*/} #this is the name of the C++ file without the starting "./", for example block.cpp
    test_name=${file_name%.*} #this is the name of the test, the file extension is removed for this: block.cpp -> block
    truncated_test_name=${test_name:1: -9}
    echo $(truncated_test_name)
    #test_name=$(jq -r '.name' $file)
    #campaign_name=projects/${PROJECT_NAME}/campaigns/${test_name}
    #echo "Campaign name: ${campaign_name}"
    
    #generate a travis CI/CD script for every fuzz target
    echo "Generating ci/${test_name}.sh"
    sed "s.TARGET_NAME.${test_name}.g" cicd_script_template.sh > ci/${test_name}.sh
    
    #Append a entry to the .travis.yml file
    echo "Append entry for ${test_name} to .travis.yml"
    sed "s.TARGET_NAME.${test_name}.g" travis_snippet >> ../.travis.yml
done
echo "All config files generated."
