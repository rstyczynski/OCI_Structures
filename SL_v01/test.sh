#!/bin/bash

source ../lib/tf_tests.sh

function test_boundle() {
    export TF_VAR_input_string="tcp/1521"
    expect_tf_answer "tcp/1521" "
dst_max=1521
dst_min=1521
protocol=tcp
"
    export TF_VAR_input_string="tcp/1521-"
    expect_tf_answer "tcp/1521-" "
dst_max=1521
dst_min=1521
protocol=tcp
"
    export TF_VAR_input_string="tcp/-1521"
    expect_tf_answer "tcp/-1521" "
dst_max=1521
dst_min=1521
protocol=tcp
"
    export TF_VAR_input_string="tcp/1521-1523"
    expect_tf_answer "tcp/1521-1523" "
dst_max=1523
dst_min=1521
protocol=tcp
"
    export TF_VAR_input_string="tcp/1023:"
    expect_tf_answer "tcp/1023:" "
src_max=1023
src_min=1023
protocol=tcp
"
    export TF_VAR_input_string="tcp/1023-:"
    expect_tf_answer "tcp/1023-:" "
src_max=1023
src_min=1023
protocol=tcp
"
    export TF_VAR_input_string="tcp/-1023:"
    expect_tf_answer "tcp/-1023:" "
src_max=1023
src_min=1023
protocol=tcp
"
    export TF_VAR_input_string="tcp/1023-1024:"
    expect_tf_answer "tcp/1023-1024:" "
src_max=1024
src_min=1023
protocol=tcp
"
    export TF_VAR_input_string="tcp/1023-1024:1521-1523"
    expect_tf_answer "tcp/1023-1024:1521-1523" "
src_max=1024
src_min=1023
dst_max=1523
dst_min=1521
protocol=tcp
"
    export TF_VAR_input_string="udp/1023-1024:1521-1523"
    expect_tf_answer "udp/1023-1024:1521-1523" "
src_max=1024
src_min=1023
dst_max=1523
dst_min=1521
protocol=udp
"

}
test_boundle
