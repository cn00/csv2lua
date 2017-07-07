#! /usr/bin/env bash

# author: cn
# email: cool_navy@qq.com
# 适用于第一行为注释，第二行为表头，逗号分割 csv 格式文本文件转 lua table
# 使用 gsed 或 自行在 sed -i 属性后添加 backup_file 名称
# 若 有安装 enca 则可自动转换为 utf-8 编码

# cygwin Darwin 测试通过

set -e

fin=$1
outdir=${2-"."}

flua="${outdir}/${fin/\.csv/\.lua}"

basepath=$(cd `dirname $0`;pwd)

tname=${fin/*\//}
tname=${tname/\.csv/}

uname=$(uname)
sed=sed
if [[ ${uname:0:6} = "Darwin" ]];then
	if [[ ! "$(which gsed)" = "" ]]; then
		sed=gsed
	else
		echo -e "place install gsed or add backup_file after all sed's \033[0;31m-i\033[m option"
		exit -1
	fi
fi

cp $fin $flua
if [[ ! "$(which enca)" = "" ]]; then
	enca -L chinese -x utf8 $flua
fi

# 表处理
$sed -f "${basepath}/csv2lua.sed" -i $flua
$sed -e '1a\\nlocal enum=(function() local i = 0;return function()i = i+1;return i end end)()\nT'${tname}'={' -i $flua

# 使用说明
$sed -e '1i\-- '"author: $(whoami)\n-- date: $(date)"'\n-- usage: T'${tname}'[id][KEY]\n' -i $flua

# 设置元表以属性方式读取子表
$sed -e '$a\}\nfor k,v in pairs(T'${tname}') do\n\tif k ~= "head" and type(v) == "table" then\n\t\tsetmetatable(v,{\n\t\t__newindex=function(t,kk) print("warning: attempte to change a readonly table") end,\n\t\t__index=function(t,kk)\n\t\t\tif T'${tname}'.head[kk] ~= nil then\n\t\t\t\treturn t[T'${tname}'.head[kk]]\n\t\t\telse\n\t\t\t\tprint("err: \\"T'${tname}'\\" have no field ["..kk.."]")\n\t\t\t\treturn nil\n\t\t\tend\n\t\tend})\n\tend\nend\nreturn T'${tname}'' -i $flua

# 预览
# less $flua