#! /usr/bin/env bash

# 测试转出 lua 表所有字段是否合法

set -e

fin=$1
cd `dirname $0`
pwd

for f in $(ls *.lua);do
	tname=${f/\.*/}
	lua -e "t${tname}=require \"${tname}\";for kk, vv in pairs(t${tname}) do for k,v in pairs(t${tname}.head)do print(\"${tname}[\"..kk..\"].\"..k..\" = \".. vv[k]) end end" 1> /dev/null
	if [[ $? = "0" ]]; then
		echo "$f test passed"
	else
		echo "$f error occurred"
	fi 
done