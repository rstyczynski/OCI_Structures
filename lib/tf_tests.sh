#!/bin/bash

tmp=~/tmp
mkdir -p $tmp

unset expect_mode
unset output_name
function expect_tf_answer() {
    export test_name=$1

    terraform plan -out=$tmp/tfplan > /dev/null

    # compare received with expected
    echo -n "$test_name "

    case $expect_mode in
    json)
        echo "$2" | sed '/^$/d'  > $tmp/expected.tmp
        terraform show -json $tmp/tfplan | 
        jq -r ".planned_values.outputs."${output_name}".value" --sort-keys  > $tmp/received_json.tmp
        cat $tmp/expected.tmp | jq --sort-keys > $tmp/expected_json.tmp
        diff $tmp/received_json.tmp $tmp/expected_json.tmp > $tmp/result.tmp
        ;;
    *)
        # prepare expected outputs
        echo "$2" | sed '/^$/d' | sort > $tmp/expected.tmp
        cat $tmp/expected.tmp | cut -d= -f1 | sed s/^/\^/g | sed s/$/=/g > $tmp/expected_outputs.tmp
 
        # extract output from tf plan
        terraform show -json $tmp/tfplan | jq -r '.planned_values.outputs' | 
        jq -r 'to_entries[] | select(.value.value != null) | "\(.key)=\(.value.value)"' | 
        sort > $tmp/outputs.tmp

        # select only expected outputs
        cat $tmp/outputs.tmp | grep -f $tmp/expected_outputs.tmp > $tmp/received.tmp

        diff $tmp/received.tmp $tmp/expected.tmp > $tmp/result.tmp
        ;;
    esac
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Error"
        cat $tmp/result.tmp
    fi
}