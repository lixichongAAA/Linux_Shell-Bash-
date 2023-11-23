# ch22 gawk进阶

gawk是一种功能丰富的编程语言，提供了各种用于编写高级数据处理程序的特性。在本章中，你将看到如何使用gawk编写程序，处理可能遇到的各种数据格式化任务。

## 1. 使用变量

gawk编程语言支持两类变量。

- 内建变量
- 自定义变量

gawk内建变量包含用于处理数据文件中的数据字段和记录的信息。

### 1. 内建变量

gawk脚本使用内建变量来引用一些特殊的功能。

#### *1. 字段和记录分隔符变量*

在第 [19](../ch19/README.md#3-使用数据字段变量) 章演示过gawk的一种内建变量——**数据字段变量**。数据字段变量允许使用美元符号和字段在记录中的位置值来引用对应的字段。因此，要引用记录中的第一个数据字段，就用变量 `$1`，要引用第二个数据字段就用 `$2`，以此类推。
数据字段由字段分隔符划定。在默认情况下，字段分隔符就是一个空白字符，也就是空格或者制表符。第 [19](../ch19/README.md#3-使用数据字段变量) 章讲过如何使用命令行选项 `-F`，或是在gawk脚本中使用特殊内建变量 `FS` 修改字段分隔符。
有一组内建变量可以控制gawk对输入数据和输出数据中字段和记录的处理方式。下表列出了这些内建变量。

|变量|描述|
| :--------: | :------------------------:|
|*FIELDWIDTHS*|由空格分隔一列数字，定义了每个数据字段的确切宽度|
|*FS*|输入字段分隔符|
|*RS*|输入记录分隔符|
|*OFS*|输出字段分隔符|
|*ORS*|输出记录分隔符|

前文介绍过如何使用变量 `FS` 定义记录中的字段分隔符，变量 `OFS` 具有相同的功能，只不过是用于 `print` 命令的输出。

默认情况下，gawk会将 `OFS` 变量设置为一个空格。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ cat data1
data11,data12,data13,data14,data15
data21,data22,data23,data24,data25
data31,data32,data33,data34,data35
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS=","}{print $1,$2,$3}' data1
data11 data12 data13
data21 data22 data23
data31 data32 data33
```

如你所见，`print` 命令自动会将 `OFS` 变量的值置于输出的每个字段之间。通过设置 `OFS` 变量，可以在输出中用任意字符串来分隔字段：

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS=","; OFS="-"}{print $1, $2, $3}' data1
data11-data12-data13
data21-data22-data23
data31-data32-data33
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS=","; OFS="<-->"}{print $1, $2, $3}' data1
data11<-->data12<-->data13
data21<-->data22<-->data23
data31<-->data32<-->data33
```

`FIELDWIDTHS` 变量可以不通过字段分隔符读取记录。有些应用程序并没有使用字段分隔符，而是将数据放置在记录中的特定列。在这种情况下，必须设定 `FIELDWIDTHS` 变量来匹配数据在记录中的位置。
一旦设置了 `FIELDWIDTHS` 变量，gawk会忽略 `FS` 变量，并根据提供的字段宽度来计算字段。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ cat data1b
1005.3247596.37
115-2.349194.00
05810.1298100.1
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FIELDWIDTHS="3 5 2 5 "}{print $1,$2,$3,$4}' data1b 
100 5.324 75 96.37
115 -2.34 91 94.00
058 10.12 98 100.1
```

`FIELDWIDTHS` 变量定义了4个数据字段，gawk以此解析记录。每个记录中的数字串会根据已定义好的字段宽度来分割。

> 一定要记住，一旦设定了 `FIELDWIDTHS` 变量的值，就不能再改动了。这种方法并不适用于变长的数据字段。

变量 `RS` 和 `ORS` 定义了gawk对数据流中记录的处理方式。在默认情况下，gawk会将 `RS` 和 `ORS` 设置为换行符。也就是说，默认情况下，输入数据流中的一行文本就是一条记录。

有时，我们会遇到数据流中占据多行的记录。如果使用默认的 `FS` 变量和 `RS` 变量来读取数据，gawk就会把每一行当作一条单独的记录来读取，并将其中的空格作为字段分隔符，这当然不是我们希望看到的。
为此，我们需要把 `FS` 变量设置为换行符。这表明数据流中的每一行都是一个单独的字段。把 `RS` 变量设置为空字符串。然后我们需要在文本数据的记录之间留一个空行。gawk会把每一个空行都视为记录分隔符。

```bash
lxc@Lxc:~/scripts/ch22$ cat data2
Ima Test
123 Main Street
Chicago, IL  60601
(312)555-1234

Frank Tester
456 Oak Street
Indianapolis, IN  46201
(317)555-9876

Haley Example
4231 Elm Street
Detroit, MI 48201
(313)555-4938
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS="\n";RS=""}{print $1,$4}' data2
Ima Test (312)555-1234
Frank Tester (317)555-9876
Haley Example (313)555-4938
```

现在，gawk会把文件中的每一行都视为一个字段，将空行视为记录分隔符。

#### *2. 数据变量*

除了字段和记录分隔符，gawk还提供了一些其他的内建变量以帮助你了解数据发生了什么变换，并提取shell环境信息。下表列出了gawk中的其它内建变量。

|变量|描述|
| :---------: | :------------------------------------------------------------------:|
|*ARGC*|命令行参数的数量|
|*ARGIND*|当前处理的文件在 *ARGV* 中的索引|
|*ARGV*|包含命令行参数的数组|
|*CONVFMT*|数字的转换格式(参见 `printf` 语句)，默认值为 %.6g|
|*ENVIRON*|当前shell环境变量及其值组成的关联数组|
|*ERRNO*|当读取或关闭文件发生错误时的系统错误号|
|*FILENAME*|用作gawk输入的数据文件的名称|
|*FNR*|当前数据文件中的记录数|
|*IGNORECASE*|设成非0值时，忽略gawk命令中出现的字符串的大小写|
|*NF*|数据文件中的字段总数|
|*NR*|已处理的输入记录数|
|*OFMT*|数字的输出显示格式。默认值为%.6g.，以浮点数或科学计数法显示，以较短者为准，最多使用6位小数|
|*RLENGTH*|由 `match` 函数所匹配的子串的长度|
|*RSTART*|由 `match` 函数所匹配的子串的起始位置|

变量 `ARGC` 和 `ARGV` 允许从shell中获取命令行参数的总数及其值。有点麻烦的地方在于gawk并不会将程序脚本视为命令行参数的一部分：

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{print ARGC, ARGV[0], ARGV[1]}' data1
2 gawk data1
```

`ARGV` 数组从索引0开始，代表的是命令。第一个数组值是gawk命令后的第一个命令行参数。

> 跟shell变量不同，在脚本中引用gawk变量时，变量名前不用加美元符号。

*ENVIRON* 变量看起来有点陌生。它使用 **关联数组** 来提取shell环境变量。关联数组用文本（而非数值）来作为数组索引。
数组索引中的文本是shell环境变量名，对应的数组元素值是shell环境变量的值。

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{
> print ENVIRON["HOME"]
> print ENVIRON["PATH"]
> }'
/home/lxc
/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
# 省略了PATH环境变量的输出
```

`NF` 变量表示数据文件中的字段总数。可以在 `NF` 变量之前加上美元符号，将其用作 *字段变量*。

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS=":";OFS=":"}{print $1, $NF}' /etc/passwd
root:/bin/bash
daemon:/usr/sbin/nologin
bin:/usr/sbin/nologin
......
```

`FNR` 变量和 `NR` 变量类似，但略有不同。*FNR* 变量包含 *当前数据文件中已处理过的记录数*，`NR` 变量则包含 *已处理过的记录总数。*

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{FS=","}
> {print $1, "FNR="FNR, "NR="NR}
> END {print "There were", NR, "records processed"}' data1 data1
data11 FNR=1 NR=1
data21 FNR=2 NR=2
data31 FNR=3 NR=3
data11 FNR=1 NR=4
data21 FNR=2 NR=5
data31 FNR=3 NR=6
There were 6 records processed
```

在这个例子中，gawk脚本在命令行指定了两个输入文件（同一个输入文件被指定了两次）。在gawk处理第二个输入文件时，`FNR` 变量的值被重置了，而 `NR` 变量则继续计数。因此，如果只使用一个数据文件作为输入，那么 `FNR` 和 `NR` 的值是相同的；如果使用多个数据文件作为输入，那么 `FNR` 的值会在处理每个数据文件时被重置，`NR` 的值则会继续计数直到处理完所有的数据文件。

### 2. 自定义变量

gawk自定义变量名称可以由任意数量的字母、数字和下划线组成，但不能以数字开头。gawk变量名区分大小写。

#### *1. 在脚本中给变量赋值*

在gawk脚本中给变量赋值与给shell脚本中的变量赋值一样，都用赋值语句：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{testing="This is a test"
> print testing
> }'
This is a test
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{
> testing = "This is a test"
> print testing 
> testing = 45 
> print testing 
> }'
This is a test
45
```

赋值语句还可以包含处理数值的数学算式：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{x = 4; x = x * 2 + 3; print x}'
11
```

gawk编程语言包含了用来处理数值的标准算术运算符，其中包括求余运算符(%)和幂运算符(^或**)。

#### *2. 在命令行中给变量赋值*

也可以通过gawk命令行来为脚本中的变量赋值。这允许你在正常的代码之外赋值，即时修改变量值。下面这个例子使用命令行变量来显示文件中特定的数据字段：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> BEGIN{x = 4; x = x * 2 + 3; print x}'
11
lxc@Lxc:~/scripts/ch22$ cat script1 
BEGIN{FS=","}
{print $n}
lxc@Lxc:~/scripts/ch22$ gawk -f script1 n=2 data1
data12
data22
data32
```

这个特性可以让你在不修改脚本代码的情况下就改变脚本的行为。

使用命令行参数来定义变量值会产生一个问题，在设置过变量之后，这个值在脚本的 `BEGIN` 部分不可用。可以用 `-v` 选项来解决这个问题，它允许在 `BEGIN` 部分之前设定变量。在命令行中， `-v` 选项必须放在脚本代码之前。

```bash
lxc@Lxc:~/scripts/ch22$ gawk -f script2 n=2 data1
The starting value is 
data12
data22
data32
lxc@Lxc:~/scripts/ch22$ gawk -v n=2 -f script2 data1
The starting value is 2
data12
data22
data32
```

现在，`BEGIN` 部分中的变量n的值就已经是命令行中设定的那个值了。

## 2. 处理数组

gawk编程语言使用 **关联数组** 来提供数组功能。与数字型数组不同，关联数组的索引可以是任意文本字符串，你不需要用连续的数字来标识数组元素。相反，关联数组用各种字符串来引用数组元素。每个索引字符串都必须能够唯一标识出分配给它的数组元素。类似于其他编程语言中的哈希表或字典。

### *1. 定义数组变量*

可以使用标准的赋值语句来定义数组变量。数组变量赋值的格式如下：

```bash
var[index] = element
```

其中 *var* 是变量名，*index* 是关联数组的索引值，*element* 是数组元素值。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{
> capital["nibaba"] = "niye"
> capital["hahaha"]="lueluelue"
> print capital["nibaba"]
> }'
niye
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{
> var[1] = 12
> var[2] = 23
> total = var[1] + var[2]
> print total
> }'
35
```

### *2. 遍历数组变量*

关联数组变量的问题在于，你可能无法预知索引是什么。如果要在gawk脚本中遍历关联数组，可以用 `for` 语句的一种特殊形式：

```bash
for (var in array)
{
    statement
}
```
这个 `for` 语句会在每次循环时将关联数组 *array* 的下一个索引值赋给变量 *var*，需要注意的是，索引值没有特定的返回顺序，然后执行一遍 *statement*。

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{
> var["a"] = 1
> var["g"] = 2
> var["m"] = 3
> var["u"] = 4
> for (test in var)
> {
> print "Index:",test, "- Value:",var[test]
> }
> }'
Index: u - Value: 4
Index: m - Value: 3
Index: a - Value: 1
Index: g - Value: 2
```

### *3. 删除数组变量*

从关联数组中删除数组元素要使用一个特殊的命令：

```bash
delete array[index]
```

`delete` 命令会从关联数组中删除索引值及其相关的数组元素值：

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{
> var["a"]=1
> var["b"]=2
> for(test in var)
> {
> print "Index:",test,"- Value:", var[test]
> }
> delete var["a"]
> print "----"
> for(test in var)
> {
> print "Index:",test,"- Value:",var[test]
> }
> }'
Index: a - Value: 1
Index: b - Value: 2
----
Index: b - Value: 2
```

## 3. 使用模式

本节将演示如何在gawk脚本中用匹配模式来限制将脚本作用于哪些记录。

### *1. 正则表达式*

你可以用基础正则表达式（BRE）或扩展正则表达式（ERE）来筛选脚本要作用于数据流中的哪些行。
在使用正则表达式时，它必须出现在与其对应脚本的左花括号前。

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS=","} /11/{print $1}' data1
data11
```

### *2. 匹配操作符*

**匹配操作符**（~）能将正则表达式限制在记录的特定数据字段。你可以指定匹配操作符、数据字段以及要匹配的正则表达式：

```bash
$1 ~ /^data/
```

`$1` 变量代表记录中的第一个数据字段。该表达式会过滤出第一个数据字段以文本 *data* 开头的所有记录。

*来个例子：*：

```bash
lxc@Lxc:~/scripts/ch22$ gawk -F: '$1 ~ /lxc/{print $1,$NF}' /etc/passwd
lxc /bin/bash
```

这个例子会在第一个数据字段查找文本 *lxc*。如果匹配该模式，则打印记录中的第一个数据字段和最后一个数据字段。

也可以用 ! 符号来排除正则表达式的匹配：

```bash
$1 !~ /expression/
```

*来个例子*：

```bash
lxc@Lxc:~/scripts/ch22$ gawk -F: '$1 !~ /lxc/{print $1,$NF}' /etc/passwd
root /bin/bash
daemon /usr/sbin/nologin
bin /usr/sbin/nologin
......
```

在这个例子中，gawk脚本会打印 */etc/passwd* 文件中用户名不是 *lxc* 的那些用户名和登录shell。

### *3. 数学表达式*

除了正则表达式，也可以在匹配模式中使用数学表达式。这个功能在匹配数据字段中的数值时非常方便。

```bash
lxc@Lxc:~/scripts/ch22$ gawk -F: '$4 == 0{print $1}' /etc/passwd
root
```

该脚本显示所有属于root用户组（组ID为0）的用户，该脚本会检查记录中值为0的第四个字段。在Linux系统中，只有一个用户账户属于root用户组。

可以使用任何常见的数学比较表达式。

- *x* == *y* : *x* 的值等于 *y* 的值
- *x* <= *y* : *x* 的值小于等于 *y* 的值
- *x* < *y* : *x* 的值小于 *y* 的值
- *x* >= *y* : *x* 的值大于等于 *y* 的值
- *x* > *y* : *x* 的值大于 *y* 的值

也可以对文本数据使用表达式，但必须小心。表达式必须完全匹配。数据必须跟模式严格匹配。

```bash
lxc@Lxc:~/scripts/ch22$ gawk -F, '$1 == "data"{print $1}' data1
lxc@Lxc:~/scripts/ch22$ gawk -F, '$1 == "data11"{print $1}' data1
data11
```

如你所见，第一个测试没有匹配任何记录，因为第一个数据字段的值不在任何记录中。第二个测试用值 *data11* 匹配了一条记录。

## 4. 结构化命令

gawk编程语言支持常见的结构化编程命令。本节将介绍这些命令并演示如何在gawk编程环境中使用它们。

### *1. `if`语句*

gawk编程语言支持标准格式的 `if-then-else` 语句。你必须为 `if` 语句定义一个求值的条件，并将其放入圆括号内。

*格式如下：*

```bash
if (condition)
    statement
```

也可以写在一行，就像下面这样：

```bash
if (condition) statement1
```

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ cat data4 
10
5
13
50
34
lxc@Lxc:~/scripts/ch22$ gawk '{if ($1 > 20) print $1}' data4 
50
34
```

如果要在 `if` 语句中执行多条语句，则必须将其放入花括号内：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> if ($1 > 20)
> {
> x = $1 * 2
> print x
> }
> }' data4
100
68
```

gawk的 `if` 语句也支持 `else` 子句，允许在 `if` 语句不成立的情况下执行一条或多条语句。来个例子：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> if ($1 > 20)
> {
> x = $1 *2
> print x
> }
> else {
> x = $1 / 2
> print x
> }
> }' data4
5
2.5
6.5
100
68
```

也可以在单行使用 `else` 子句，但必须在 `if` 语句部分之后使用分号：

```bash
if (condition) statement1; else statement2
```

下面是上一个例子的单行格式版本：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{if($1 > 20) print $1 * 2; else print $1 / 2}' data4
5
2.5
6.5
100
68
```

### *2. `while` 语句*

*语句格式：*

```bash
while(condition)
{
    statement
}
```

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ cat data5 
130 120 135
160 113 140
145 170 215
lxc@Lxc:~/scripts/ch22$ gawk '{
> total = 0
> i = 1
> while(i < 4)
> {
> total += $i
> i++
> }
> avg = total / 3
> print "Avgerage:", avg
> }' data5
Avgerage: 128.333
Avgerage: 137.667
Avgerage: 176.667
```

gawk编程语言支持在 `while` 循环中使用 `break` 语句和 `continue` 语句。

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> total = 0
> i = 1
> while(i < 4)
> {
> total += $i
> if(i == 2)
> break
> i++
> }
> avg = total / 2
> print "Average:",avg
> }' data5
Average: 125
Average: 136.5
Average: 157.5
```

在 i 等于 2 时，`break` 语句跳出 `while` 循环。

### *3. `do-while`语句*

*语句格式：*

```bash
do
{
    statements
}while(condition)
```

这种格式保证在 *statements* 会在条件被求值前至少被执行一次。

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> total = 0
> i = 1
> do
> {
> total += $i
> i++
> }while(total < 150)
> print total}' data5
250
160
315
```

### *4. `for`语句*

gawk编程语言支持C风格的 `for` 循环：

```bash
for(variable assignment; condition; iteration process)
```

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> total = 0
> for(i = 1; i < 4; i++)
> {
> total += $i
> }
> avg = total / 3
> print "Average:", avg
> }' data5
Average: 128.333
Average: 137.667
Average: 176.667
```

## 2. 格式化打印

gawk编程语言提供了格式化打印命令 `printf`。如果你熟悉C语言，那么gawk中 `printf` 命令的用法也是一样的。

`printf` 命令的格式如下：

```bash
printf "format string", var1, var2
```

*format string* 是格式化输出的关键。它会用文本元素和 **格式说明符（format specifier**）来具体指定如何呈现格式化输出。格式说明符是一种特殊的代码，可以指明显示什么类型的变量以及如何显示。gawk脚本会将每个格式说明符作为占位符，供命令中的每个变量使用。第一个格式说明符对应第一个变量，第二个对应第二个变量，以此类推。

*格式说明符的格式如下：*

```bash
%[modifier] control-letter
```

其中， *control-letter* 是控制字母，用于指明显示什么类型的数据，*modifier* 是修饰符，定义了可选的格式化特性。

下表列出了在格式说明符中可用的控制字母。

|控制字母|描述|
| :--: | :----------------------------------------: |
|*c*|将数字作为ASCII字符显示|
|*d*|显示整数值|
|*i*|显示整数值（和 *d* 一样）|
|*e*|用科学计数法显示数字|
|*f*|显示浮点数|
|*g*|用科学计数法或浮点数显示（较短的格式优先）|
|*o*|显示八进制|
|*s*|显示字符串|
|*x*|显示十六进制|
|*X*|显示十六进制，但用大写字母A~F|

除了控制字母，还有3种修饰符可以进一步控制输出。

- *width* : 指出输出字段的最小宽度。如果输出短于这个值，则 `printf` 语句会将文本右对齐，并用空格进行填充。如果输出比指定的宽度长，则按照实际长度输出。
- *prec* : 指定浮点数中小数点右侧的位数或者字符串中显示的最大字符数。
- \-（减号）: 指明格式化空间中的数据采用左对齐而非右对齐。

*下面来几个例子：*

```bash
lxc@Lxc:~/scripts/ch22$ gawk 'BEGIN{FS="\n";RS=""}{printf "%s %s\n", $1, $4}' data2
Ima Test (312)555-1234
Frank Tester (317)555-9876
Haley Example (313)555-4938
```

注意，你需要在 `printf` 命令的末尾手动添加换行符，以便生成新行。否则，`printf` 命令会继续在同一行打印后继续输出。

```bash
$ gawk 'BEGIN{FS="\n";RS=""}{printf "%16s %s\n", $1, $4}' data2 
        Ima Test (312)555-1234
    Frank Tester (317)555-9876
   Haley Example (313)555-4938
```

通过添加一个值为16的修饰符，我们强制第一个字符串的宽度为16字符。在默认情况下，`printf` 命令使用右对齐来讲数据放入格式化空间中。要改为左对齐，只需给修饰符加上一个减号即可：

```bash
$ gawk 'BEGIN{FS="\n";RS=""}{printf "%-16s %s\n", $1,$4}' data2
Ima Test         (312)555-1234
Frank Tester     (317)555-9876
Haley Example    (313)555-4938
```

`printf` 命令在处理浮点值时也很方便。通过为变量指定格式，可以使输出看起来更为统一：

```bash
lxc@Lxc:~/scripts/ch22$ gawk '{
> total = 0
> for(i = 1; i < 4; i++)
> {
> total += $i
> }
> avg = total / 3
> printf "Average: %5.1f\n", avg
> }' data5
Average: 128.3
Average: 137.7
Average: 176.7
```

格式说明符 `%5.1f` 强制 `printf` 命令将浮点值近似到小数点后一位。

## 6. 内建函数

gawk编程语言提供了不少内置函数，以用于执行一些常见的数学、字符串以及时间运算。本节将带你逐步熟悉gawk编程语言中的各种内建函数。

### *1. 数学函数*

下表列出了gawk中内建的数学函数。

|函数|描述|
| :-------: | :---------------------: |
|atan2(x, y)|x/y的反正切，x和y以弧度为单位|
|cos(x)|x的余弦，x以弧度为单位|
|exp(x)|e的x次方|
|int(x)|x的整数部分，取靠近0的一侧|
|log(x)|x的自然对数|
|rand()|比0大且比1小的随机浮点值|
|sin(x)|x的正弦，x以弧度为单位|
|sqrt(x)|x的平方根|
|srand(x)|为计算随机数指定一个种子值|

`rand` 函数会返回一个随机数，但这个随机数只在0和1之间（不包括0或1）。要得到更大的数，就需要放大返回值。产生较大随整数的常见方法是综合运用函数 `rand()` 和 `int()` 创建一个算法：

```bash
x = int(10 * rand())
```

这会返回一个0~9（包括0和9）的随机整数值。只要在程序中用上限值替换等式中的10就可以了。

在使用一些数学函数时要小心，因为gawk编程语言对于能够处理的数值有一个限定区间。如果超出这个区间，就会得到一条错误消息：

```bash
lxc@Lxc:~/scripts$ gawk 'BEGIN{x=exp(100); print x}'
26881171418161356094253400435962903554686976
lxc@Lxc:~/scripts$ gawk 'BEGIN{x=exp(1000); print x}'
gawk: 命令行:1: 警告： exp：参数 1000 超出范围
+inf
```

第一个例子计算e的100次幂，虽然这个数值很大但尚在系统的区间以内。第二个例子尝试计算e的1000次幂，这已经超出了系统的数值区间，因此产生了一条错误消息。

除了标准数学函数，gawk还支持一些按位操作数据的函数。

- and(v1, v2) : 对v1和v2执行按位AND运算。
- compl(val) : 对val执行补运算。
- lshift(val, count) : 将val左移count位。
- or(v1, v2) : 对v1和v2执行按位OR运算。
- rshift(val, count) : 将val右移count位。
- xor(v1, v2) : 对v1和v2执行按位XOR运算。

### *2. 字符串函数*

不多bb了，如下表所示：

|函数|描述|
| :----------------: | :---------------------------------------------------------: |
|asort(s [,d])|将数组 *s* 按照元素值排序。索引会被替换成表示新顺序的连续数字。如果指定了 *d*，则排序后的数组会被保存在数组 *d* 中|
|asorti(s [,d])|将数组 *s* 按索引排序。生成的数组会将索引作为数组元素值，用连续数字索引表明排序顺序。如果指定了 *d*，则排序后的数组会被保存在数组 *d* 中|
|gensub(r,s, h[,t])|针对变量$0或目标字符串 *t* (如果提供了的话)来匹配正则表达式 *r*。如果 *h* 是一个以 *g* 或 *G* 开头的字符串，就用 *s* 替换匹配的文本。如果 *h* 是一个数字，则表示要替换 *r* 的第 *h* 处匹配|
|gsub(r,s [,t])|针对变量$0或目标字符串 *t* (如果提供了的话)来匹配正则表达式 *r*。如果找到了，就将所有的匹配之处全部替换成字符串 *s*|
|index(s,t)|返回字符串 *t* 在字符串 *s* 中的索引位置；如果没找到，就返回0|
|length(s)|返回字符串 *s* 的长度；如果没有指定，则返回$0的长度|
|match(s,r [,a])|返回正则表达式 *r* 在字符串 *s* 中匹配位置的索引。如果指定了数组 *a*，则将 *s* 的匹配部分保存到该数组中|
|split(s, a [,r])|将 *s* 以FS(字段分隔符)或正则表达式 *r* (如果指定了的话)分割并放入数组 *a* 中。返回分割后的字段总数|
|sprintf(*format*, *variables*)|用提供的 *format* 和 *variables* 返回一个类似于 `printf` 输出的字符串|
|sub(r,s,[,t])|在变量$0或字符串 *t* 中查找匹配正则表达式 *r* 的部分。如果找到了，就用字符串 *s* 替换第一处匹配|
|substr(s,i [,n])|返回 *s* 中从索引 *i* 开始、长度为 *n* 的子串。如果未提供 *n*，则返回 *s* 中剩下的部分|
|tolower(s)|将 *s* 中所有字符都转换为小写|
|toupper(s)|将 *s* 中所有字符都转换为大写|

有些字符串函数的作用显而易见：

```bash
lxc@Lxc:~/scripts$ gawk 'BEGIN{x = "testing"; print toupper(x); print length(x)}'
TESTING
7
```

有些字符串函数的用法较为复杂。`asort` 和 `asorti` 是新加入的gawk函数，允许基于数据元素值(asort)或索引(asorti)对数组变量进行排序。

```bash
lxc@Lxc:~/scripts$ gawk 'BEGIN{
> var["a"] = 1
> var["g"] = 2
> var["m"] = 3
> var["u"] = 4
> asort(var, test)
> for(i in test)
> {
> print "Index:",i, " - Value:",test[i]
> }
> }'
Index: 1  - Value: 1
Index: 2  - Value: 2
Index: 3  - Value: 3
Index: 4  - Value: 4
```

新数组 *test* 包含经过排序的原数组的数据元素，但数组索引变成了表明正确顺序的数字值。

`split` 函数是将数据字段放入数组以供进一步处理的好方法：

```bash
$ gawk 'BEGIN{FS=","}{
split($0, var)
print var[1],var[5]
}' data1
data11 data15
data21 data25
data31 data35
```

新数组使用连续数字作为数组索引，从含有第一个数据字段的索引值1开始。

### *3. 时间函数*

时间戳（timestamp）是自1970-01-01 00:00:00 UTC 到现在，以秒为单位的计数，通常称为纪元时（epoch time）。gawk编程语言也有一些处理时间的函数，如下表所示：

|函数|描述|
| :------------------: | :-------------------------------------------------------: |
|mktime(*datespec*)|将一个按YYYY MM DD HH MM SS (DST)格式指定的日期转换为时间戳|
|strftime(*format* [, *timestamp*])|将当前时间戳或 *timestamp*（如果提供了的话）转换为格式化日期（采用shell `date` 命令的格式）|
|systime()|返回当前时间的时间戳|

时间函数多用于处理日志文件。日志文件中通常含有需要进行比较的日期。通过将日期的文本表示形式转换为纪元时，可以轻松地比较日期。

```bash
$ gawk 'BEGIN{
> data = systime()
> day = strftime("%A, %B, %d, %Y", date)
> print day
> }'
星期四, 一月, 01, 1970
```

这个例子用 `systime` 函数从系统获取当前的时间戳，然后用 `strftime` 函数将其转换成用户可读的格式，转换过程中用到了shell命令 `date` 的日期格式化字符。

## 7. 自定义函数

要定义自己的函数，必须使用关键字 `function` ：

```bash
function name([variables])
{
    statements
}
```

函数名必须能够唯一标识函数。你可以在调用该函数的gawk脚本中向其传入一个或多个变量：

```bash
function printthird()
{
    print $3
}
```

这个函数会打印记录中的第三个字段。

函数还可以使用 `return` 语句返回一个值。

```bash
return value
```

返回的这个值既可以是变量，也可以是最终能计算出值的算式：

```bash
function myrand(limit)
{
    return int(limit * rand())
}
```

可以将函数返回值赋给gawk脚本中的变量：

x = myrand(100)

这个变量包含函数的返回值。

### *2. 使用自定义函数*

在定义函数时，它必须出现在所有代码块之前（包括 `BEGIN` 代码块）。

```bash
lxc@Lxc:~/scripts/ch22$ gawk '
> function myprint()
> {
> printf "%-16s %s\n", $1, $4
> }
> BEGIN{FS="\n";RS=""}
> {
> myprint()
> }' data2
Ima Test         (312)555-1234
Frank Tester     (317)555-9876
Haley Example    (313)555-4938
```

### *3. 创建函数库*

gawk提供了一种方式以将多个函数放入单个库文件中，这样就可以在所有的gawk脚本中使用了。

首先需要创建一个包含所有gawk函数的文件：

```bash
lxc@Lxc:~/scripts/ch22$ cat funclib1 
function myprint()
{
  printf "%-16s - %s\n", $1, $4
}
function myrand(limit)
{
  return int(limit * rand())
}
function printthird()
{
  print $3
}
```

`-f` 选项不能和内联gawk脚本(inline gawk script)一起使用，不过可以在同一命令行中使用多个 `-f` 选项。因此，要使用库，只要创建好gawk脚本文件，然后在命令行中同时指定库文件和脚本文件即可：

```bash
lxc@Lxc:~/scripts/ch22$ cat script4 
BEGIN{ FS="\n"; RS=""}
{
    myprint()
}
lxc@Lxc:~/scripts/ch22$ gawk -f funclib1 -f script4 data2 
Ima Test         - (312)555-1234
Frank Tester     - (317)555-9876
Haley Example    - (313)555-4938
```

## 8. 实战演练

[bowling.sh](./bowling.sh)

```bash
lxc@Lxc:~/scripts/ch22$ cat scores.txt 
Rich Blum,team1,100,115,95
Barbara Blum,team1,110,115,100
Christine Bresnahan,team2,120,115,118
Tim Bresnahan,team2,125,112,116
# output:
lxc@Lxc:~/scripts/ch22$ ./bowling.sh 
Total for team1 is 635 ,the average is 105.833
Total for team2 is 706 ,the average is 117.667
```

该脚本计算出每队的总分和平均分。

```bash
#!/bin/bash

for team in $(gawk -F, '{print $2}' scores.txt | uniq)
do
    gawk -v team=$team 'BEGIN{FS=","; total=0}
    {
        if ($2 == team)
        {
            total += $3 + $4 + $5
        }
    }
    END {
        avg = total / 6
        print "Total for", team, "is", total, ",the average is", avg
    }' scores.txt
done
```