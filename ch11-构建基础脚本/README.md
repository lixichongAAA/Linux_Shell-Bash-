# ch11 构建基础脚本

## 11.1 使用多个命令

如果想让两个命令一起运行，可以将其放在同一行，彼此用分号隔开:

```bash
date ; who
```

可以将多个命令串在一起使用，只要不超过命令行最大字符数 **255** 就行，shell会按顺序逐个执行。其实就是命令列表，参见 [第5章](../ch05/README.md#1-查看进程列表)。

## 11.2 创建shell脚本文件

在创建shell时，必须在第一行指定要使用的shell，格式如下：

```bash
#!/bin/bash
```

在普通的shell脚本中，`#`用作注释行。shell并不会处理shell脚本中的注释行。然而，shell脚本的第一行是个例外，`#`号后面的`!`用于告诉shell用哪个shell来运行脚本。（可以使用bash shell，然后使用另一个shell来运行你的脚本。）

## 11.3 显示消息

大多数shell命令会产生自己的输出，这些输出会显示在脚本运行的控制台显示器上。  
你可以通过 `echo` 命令来显示自己添加的消息。`echo` 命令可用单引号或者双引号来划定字符串。如果你在字符串中用到某种引号，可以使用另一种引号来划定字符串。 

*例如：*

```bash
lxc@Lxc:~/scripts/ch11$ echo 'lxc says "scripting is easy"'
lxc says "scripting is easy"
```

> 使用 `echo` 命令时，若不想输出尾随换行符，可以使用 `-n` 选项。

## 11.4 使用变量

### 1. *环境变量*

shell维护着一组用于记录特定系统信息的环境变量，比如系统名称、已登陆系统的用户名、用户的系统ID（UID）、用户的默认主目录以及shell查找程序的搜索路径等。  
你可以使用 `set` 命令显示一份完整的当前环境变量列表。参见 [第6章](../ch06/README.md#2-局部环境变量)

在脚本中，可以在环境变量名之前加上 `$` 符号来引用这些环境变量。参见 [test2](./test2)

如果你想在双引号中原生的显示 `$` 符号，必须在它前面放置一个反斜线:

```bash
echo "The cost of the item is \$15"
# output: The cost of the item is $15
```

> 也可以使用 `${variavle}` 形式引用变量。花括号通常用于帮助界定`$`后面的变量名.

### 2. *用户自定义变量*

- 用户自定义变量的名称可以是由任意 **字母、数字、下划线** 组成的字符串，长度不超过 **20** 个字符，区分大小写。
- 注意：使用等号为变量赋值，在变量、等号和值之间 **不能** 出现空格。
- shell脚本会以 **字符串** 的形式存储所有的变量值，脚本中的各个命令自行决定变量值的数据类型。
- shell脚本中定义的变量在脚本的整个生命周期里会一直保持它们的值，在脚本结束时被删除。

[test3](./test3) [test4](./test4)

### 3. *命令替换*

有两种方法可以将命令输出赋给变量。

- 反引号 \`
- `$()` 格式

*例如：*

```bash
testing=`date`
```

或者

```bash
testing=$(date)
```

[test5](./test5)

> **警告：** 命令替换会创建出子shell来运行指定命令，这是由运行脚本的shell所生成的一个独立的shell。**因此，在子shell中运行的命令无法使用脚本中的变量**。 如果在命令行中使用`./`路径执行命令，就会创建子shell，但如果不加路径，则不会创建子shell。不过，内建的shell命令也不会创建子shell。

## 11.5 重定向输入输出

### 1. 输出重定向

*命令格式：*

```bash
command > outputfile
```

*例如：*

```bash
date > test6.txt
```

最基本的重定向会将命令输出发送至文件。bash shell使用 `>` 来实现该操作（若文件已存在，则覆盖）。  
若你不想覆盖文件原有内容，可以使用 `>>` 来将命令输出追加到已有文件中。

### 2. 输入重定向

输入重定向将文件内容重定向至命令，使用 `<` 实现。  

*命令格式：*

```bash
command < inputfile
```

*例如：*

```bash
wc < test6.txt
```

**内联输入重定向（inline input redirection）** 使用 `<<` 号，无须使用文件进行重定向，只需在命令行中指定用于输入重定向的数据即可。必须指定一个文本标记，任何字符串都可以作为文本标记，文本标记用来划分输入数据的起止(起止的文本标记必须一致)：

*命令格式：*

```bash
command << marker
data
data
marker
```

*例如：*

```bash
wc << EOF
> test string 1
> test string 2
> test string 3
> EOF

# output 3 9 42
```

次提示符（由 `PS2`环境变量定义）会持续显示，直到输入了作为文本标记的那个字符串。`wc` 命令统计了数据的 行数、单词数、字节数。

## 11.6 管道

*管道* 可以将一个命令的输出作为另一个命令的输入，管道可以串联的命令数量没有限制。

*命令格式：*

```bash
command1 | command2
```

> **不要认为管道串联起来的命令会依次执行，Linux系统会同时运行这两个命令**，当第一个命令产生输出时，
它会被立即传给第二个命令。数据传输不会用到任何中间文件或者缓冲区。

有些命令的输出会在屏幕上一闪而过，我们可以使用管道将其输出传给文本分页命令（`more` 或者`less`），来强行将输出按屏显示。

## 11.7 执行数学运算

shell脚本在执行数学运算这方面多少有点不尽如人意。在shell脚本中执行数学运算有两种方式。

### *1. ~~expr 命令~~*

~~该命令十分笨拙~~，可以识别少量算术运算符和字符串运算符，如下表所示：

|运算符|描述|
| :------------------: | :--------------------------------: |
| ARG1 \| ARG2 | 如果 ARG1 既不为null也不为0，就返回 ARG1 ；否则，返回 ARG2|
| ARG1 & ARG2  | 如果 ARG1 和 ARG2 都不为null或者0，就返回 ARG1；否则返回0|
| ARG1 < ARG2  | 如果 ARG1 小于 ARG2，返回1；否则，返回0|
| ARG1 <= Arg2 | 如果 ARG1 小于或者等于 ARG2，返回1；否则，返回0|
| ARG1 = ARG2  | 如果 ARG1 等于 ARG2，返回1；否则，返回0|
| ARG1 != ARG2 | 如果 ARG1 不等于 ARG2，返回1；否则，返回0|
| ARG1 >= ARG2 | 如果 ARG1 大于或者等于 ARG2，返回1；否则，返回0|
| ARG1 > ARG2  | 如果 ARG1 大于 ARG2，返回1；否则，返回0|
| ARG1 + ARG2  | 返回 ARG1 和 ARG2 之和|
| ARG1 - ARG2  | 返回 ARG1 和 ARG2 之差|
| ARG1 * ARG2  | 返回 ARG1 和 ARG2 之积|
| ARG1 / ARG2  | 返回 ARG1 和 ARG2 之商|
| ARG1 % ARG2  | 返回 ARG1 和 ARG2 之余数|
| STRING : REGEXP | 如果 REGEXP 模式匹配 STRING ，则返回该模式匹配的内容|
| match STRING REGEXP | 如果 REGEXP 模式匹配 STRING ，则返回该模式匹配的内容|
| substr STRING POS LENGTH| 返回起始位置为POS（从1开始计数）、长度为LENGTH的子串|
| index STRING CHARS | 返回 CHARS 在字符串 STRING 中所处的位置；否则，返回0|
| length STRING | 返回字符串 STRING 的长度|
| + TOKEN | 将 TOKEN 解释成字符串，即使 TOKEN 属于关键字|
| (EXPRESSION) | 返回 EXPRESSION 的值|

> 许多 *expr* 命令运算符在shell中另有他意（比如 `*`）。当这些符号出现在 *expr* 命令中时，
会产生诡异的结果，**所以，一些符号需要转义**。

```bash
expr 5 * 2
# output: syntax error
```

*正确的应为：*

```bash
expr 5 \* 2
# output 10
```

确实难看，在shell脚本中使用 `expr` 命令也同样麻烦。[test6](./test6)  
所以我们使用下面的方法。

### 2. *使用方括号*

- 为了兼容Bourne shell，所以bash shell 保留了 *expr* 命令，同时也提供了更方便的方式来执行数学运算。
- 在bash中，要将数学运算的结果赋给变量，可以使用 `$` 和 `[]`，就像这样: (`$[ operation ]`) 。  
在使用方括号时，无须担心shell会误解乘号或其他符号。

*例如：*

[test7.sh](./test7) 

```bash
#!/bin/bash

var1=100
var2=50
var3=45
var4=$[$var1 * ($var2 - $var3)]
echo "The final result is $var4"
```
> bash shell的数学运算符只支持整数运算，z shell(zsh)提供了完整的浮点数操作。如果需要在shell脚本中执行浮点数运算，那么不妨考虑一下z shell（参见 [第23章](../ch23/README.md#4-zsh-shell)）。

### 3. *浮点数解决方案*

可以使用内建的bash计算器 `bc`

#### *1.bc的基本用法*

`bc`计算器实际上是一种编程语言，允许在命令行输入浮点数表达式，然后解释并计算该表达式并返回结果。  
`bc`计算器能够识别以下内容。

- 数字（整数和浮点数）
- 变量（简单变量和数组）
- 注释（以`#`或C语言中的`/**/`开始的行）
- 表达式
- 编程语句（比如 *if-then* 语句）
- 函数

你可以在shell提示符下通过 `bc` 命令访问bash计算器，输入 `quit` 退出。  
`scale` 变量控制 `bc` 输出结果保留的位数，默认为0。

```bash
lxc@Lxc:~/scripts/ch11$ bc
bc 1.07.1
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006, 2008, 2012-2017 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 
12 * 5.4
64.8
3.156 * (3 + 5)
25.248
quit
```

浮点数运算由内建变量 `scale` 控制，默认值为0。你必须将该变量的值设置为希望在结果中保留的小数位数。

```bash
lxc@Lxc:~/scripts/ch11$ bc -q
3.44 / 5
0
scale=4
3.44/5
.6880
quit
```

`-q` 选项可以不显示bash计算器冗长的欢迎信息。

除了普通数字，bash计算器还支持变量：

```bash
lxc@Lxc:~/scripts/ch11$ bc -q
var1=10
var1 * 4
40
var2 = var1 / 5
print var2
2
quit
```
#### *2.在脚本中使用bc*

可以使用 *命令替换* 将 `bc` 命令的输出赋给变量。

*命令格式：*

```bash
variable=$(echo "options; expression" | bc)
```

*例如：*

[test9.sh](./test9)

```bash
#!/bin/bash
var1=$(echo "scale=4; 3.44 / 5" | bc)
echo "The answer is $var1"
# output：
lxc@Lxc:~/scripts/ch11$ ./test9 
The answer is .6880
```

[test10](./test10) [test11](./test11)

这种方法适用于较短的运算，但有时你需要涉及更多的数字。如果要进行大量运算，那么在一个命令行中列出多个表达式容易让人犯晕。最好的方法是使用内联输入重定向。

[test12.sh](./test12)

```bash
#!/bin/bash
var1=10.46
var2=43.67
var3=33.2
var4=71

var5=$(bc << EOF
scale=4
a1 = $var1 * $var2
a2 = $var3 * $var4
a1 + b1
EOF
)
echo The final answer for this mess is $var5
```

还要注意到，在这个例子中，可以在bash计算器中为变量赋值，但是在bash计算器中创建的变量仅在计算器中有效，不能在shell脚本中使用。

## 11.8 退出脚本

shell中运行的每个命令都使用 **退出状态码** 来告诉shell自己已经运行完毕。  
退出状态码是一个 **0~255** 的整数值，在命令结束运行时传给shell，你可以获取这个值并在脚本中使用。

### *1. 查看退出状态码*

Linux提供了专门的变量 `$?` 来保存最后一个已执行命令的退出状态码。按照惯例，成功结束的命令，其退出状态码为0。因错误而结束的命令，其退出状态码为正整数。  
Linux错误退出状态码没有什么标准可循。但有一些可用的指南，如下：

|状态码|描述|
| :--: | :-------: |
|0| 命令成功结束 |
|1| 一般性未知错误(如命令参数错误)|
|2| 不适合的shell命令|
|126| 命令无法执行(没有权限)|
|127| 没找到命令(你打错字了)|
|128| 无效的退出参数|
|128+*x*| 与Linux信号*x*相关的严重错误|
|130| 通过 `Ctrl+C` 终止的命令|
|255| 正常范围之外的退出状态码|

### *2. exit 命令*

在默认情况下，shell脚本会以脚本中的最后一个命令的退出状态码退出。  
你可以改变这种行默认为，返回自己的退出状态码。 `exit` 命令允许在脚本结束时指定一个退出状态码:

[test13.sh](./test13)

```bash
#!/bin/bash
# testing the exit status
var1=10
var2=30
var3=$[ $var1 + $var2 ]
echo The final result is $var3
exit 5
# output:
lxc@Lxc:~/scripts/ch11$ ./test13 
The final result is 40
lxc@Lxc:~/scripts/ch11$ echo $?
5
```

也可以使用变量作为 `exit` 命令的参数：

[test14](./test14)

```bash
#!/bin/bash
# testing the exit status
var1=10
var2=30
var3=$[ $var1 + $var2 ]
echo The final result is $var3
exit $var3
# output:
lxc@Lxc:~/scripts/ch11$ ./test14
The final result is 40
lxc@Lxc:~/scripts/ch11$ echo $?
40
```

> 注意：退出状态码最大为 255 ，若大于该值，则为除以256的余数。

[test14b.sh](./test14b)

```bash
#!/bin/bash
# testing the exit status
var1=10
var2=30
var3=$[ $var1 * $var2 ]
echo The final result is $var3
exit $var3 # 300 % 256 = 44
# output:
lxc@Lxc:~/scripts/ch11$ ./test14b 
The final result is 300
lxc@Lxc:~/scripts/ch11$ echo $?
44
```

## 9. 实战演练

我们搞一个脚本来计算两个日期之间相隔的天数：

[mydate.sh](./mydate.sh)

```bash
#!/bin/bash
# calculate the number of days between two dates
date1="Jan 1, 2020"
date2="May 1, 2020"

time1=$(date -d "$date1" +%s)
time2=$(date -d "$date2" +%s)
diff=$(expr $time2 - $time1)
secondsinday=$(expr 24 \* 60 \* 60)
days=$(expr $diff \/ $secondsinday)

echo "The difference in $date1 and $date2 is $days days"
```

`date` 命令允许使用 `-d` 选项指定特定日期（以任意格式）。为了执行日期运算，要利用到 **纪元时间（epoch time）** 这个Linux特性。纪元时间将时间指定为自1970年1月1日后的整秒数。`date` 命令的 `%s` 格式：seconds since 1970-01-01 00:00:00 UTC。得到两个日期的纪元时间，相减，除以一天中的秒数，以获得两个日期之间的天数差异。
