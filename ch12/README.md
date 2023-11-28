# ch12 结构化命令

有一类命令允许脚本根据条件跳过部分命令，改变执行流程。这样的命令通常称为 **结构化命令（structured command）**。

## 12.1 使用 *if-then* 语句

*语句格式:*

```bash
if command
then
    commands
fi
```

[test1.sh](./test1.sh) [test2.sh](./test2.sh) [test3.sh](./test3.sh)

bash shell的 `if` 语句会运行 `if` 之后的命令。如果该命令的退出状态码为0（命令成功运行），那么位于`then` 部分的命令就会被执行。若为其它值，则不会被执行。

注意，*`if-then`* 语句还有另一种形式：

```bash
if command; then
    commands
fi
```
通过将分号写在待求值的命令尾部，可以将 *`then`* 语句写在同一行，这样看起来更像其他编程语言中的 *`if-then`* 语句。

## 12.2 *if-then-else* 语句

当 *`if`* 语句中的命令返回退出状态码为0时，*`then`* 部分中的命令会被执行，这跟普通的 *`if-then`* 语句一样。当 *`if`* 语句中的命令返回非0的退出状态码时，bash shell会执行 *`else`* 部分的命令。

*语句格式:*

```bash
if command
then    
    commands
else
    commands
fi
```

[test4.sh](./test4.sh)

## 12.3 嵌套 *if* 语句

*语句格式:*

```bash
if command1
then 
    command set 1
elif command2
then
    command set 2
elif comman3
then 
    command set 3
fi 
```

[test5.sh](./test5.sh)

## 12.4 test 命令

`if-then` 语句不能测试命令退出状态码之外的条件。  
我们可以使用 `test` 测试不同条件，如果 `test` 命令中列出的条件成立，那么 `test` 命令就会退出并返回退出状态码 0 。这样 `if-then` 语句的工作方式就和其他编程语言中的 `if-then` 语句差不多了。

*`test` 命令格式：*

```bash
test condition
```

当用在 `if-then` 语句中时：

*语句格式:*

```bash
if test condition
then
    commands
fi
```

*例如：*

[test6.sh](./test6.sh) [test6b.sh](./test6_b.sh)

```bash
my_variable="Full"
# 这里my_variable变量非空，所以test会返回0。否则，则会执行else分支。
if test $my_variable
then
    echo "The my_variable variable has content and returns a True."
    echo "The my_variable variable content is $my_variable."
else
    echo "The my_variable variable doesn't have content,"
    echo "and return a False."
fi
```

bash shell中提供了另一种 *条件测试* 方式，无须在 `if-then` 语句中写明 `test` 命令：

```bash
if [ condition ]
then
    commands
fi
```

> **注意:** 第一个方括号之后和第二个方括号之前**必须留有空格**，否则会出错.

`test` 命令和 *测试条件* 可以判断以下3类条件

### *1. 数值比较*

|比较|描述|
| :-------: | :------------------------: |
|*n1* -eq *n2* |检查 *n1* 是否等于 *n2* |
|*n1* -ge *n2*|检查 *n1* 是否大于或等于 *n2*|
|*n1* -gt *n2*|检查 *n1* 是否大于 *n2*|
|*n1* -le *n2*|检查 *n1* 是否小于或等于 *n2*|
|*n1* -lt *n2*|检查 *n1* 是否小于 *n2*|
|*n1* -ne *n2*|检查 *n1* 是否不等于 *n2*|

[numberic_test.sh](./numeric_test.sh)

```bash
#!/bin/bash
# using numeric test evaluations

value1=10
value2=11
# 
if [ $value1 -gt 5 ]
then 
    echo "The test value $value1 is greater than 5."
fi

if [ $value1 -eq $value2 ]
then 
    echo "The value are equal."
else
    echo "The value are different."
fi
```

> **注意：** 对于条件测试。bash shell只能处理整数，尽管可以将浮点值用于某些命令(比如 `echo` )， 但它们在条件测试下无法正常工作。

### 2. 字符串比较

|比较|描述|
| :-------:| :------------------------: |
|*str1* = *str2* |检查 *str1* 是否和 *str2*相同|
|*str1* != *str2*|检查 *str1* 是否和 *str2*不同|
|*str1* < *str2* |检查 *str1* 是否小于 *str2*|
|*str1* > *str2* |检查 *str1* 是否大于 *str2*|
|-n *str1*       |检查 *str1* 的长度是否不为 0|
|-z *str1*       |检查 *str1* 的长度是否为 0|

#### *1. 字符串相等性比较*

[string_test.sh](./string_test.sh)

```bash
#!/bin/bash
# using string test evaluations
# 
testUser=lxc
# 
if [ $testUser = lxc ]
then
    echo "The testUser variable contains: lxc"
else
    echo "ths testUser variable contains: $testUser"
fi
```

#### *2. 字符串顺序*

使用条件测试的大于或小于功能时，会出现两个经常困扰shell程序员的问题。

- 在 *条件测试* 中大于号和小于号 **必须** 转义，否则会被shell视为重定向符，将字符串当作文件名。
- 大于和小于顺序和 `sort` 命令采用的比较不同

`sort` 命令使用的是系统语言环境设置中定义的排序顺序。比较测试中使用的是标准的Unicode顺序，根据每个字符的Unicode编码值来决定排序结果.

[good_string_comparison.sh](./good_string_comparison.sh)

```bash
#!/bin/bash
# Properly using string comparisons
#
string1=soccer
string2=zorbfootball
#
if [ $string1 \> $string2 ]
then
     echo "$string1 is greater than $string2"
else
     echo "$string1 is less than $string2"
fi
```

第二个问题更细微。`sort` 命令处理大写字母的方法刚好与 `test` 命令相反。

[sort_order_comparison.sh](./sort_order_comparison.sh)

```bash
lxc@Lxc:~/scripts/ch12$ cat SportsFile.txt 
Soccer
soccer
lxc@Lxc:~/scripts/ch12$ sort SportsFile.txt 
soccer
Soccer
lxc@Lxc:~/scripts/ch12$ ./sort_order_comparison.sh 
Soccer <= soccer.
lxc@Lxc:~/scripts/ch12$ cat sort_order_comparison.sh 
#!/bin/bash
# Testing string sort order
# 
string1=Soccer
string2=soccer
# 
if [ $string1 \> $string2 ]
then
    echo "$string1 > $string2."
else
    echo "$string1 <= $string2."
fi
# Shell 使用Unicode编码值比较大小
```

在脚本的比较测试中大写字母被认为是小于小写字母的。但 `sort` 命令正好相反。这是由于各个命令使用了不同的排序技术。  
比较测试中（即脚本中的条件测试）使用的是标准的Unicode顺序，根据每个字符的Unicode编码值来决定排序结果。`sort` 命令使用的系统的语言环境设置中定义的顺序。对于英语，语言环境设置指定了在排序顺序中小写字母出现在大写字母之前。

#### *3. 字符串大小*

`-n` 和 `-z` 可以很方便地用于检查一个变量是否为空：

[variable_content_eval.sh](./variable_content_eval.sh)

```bash
#!/bin/bash
# Testing string length
# -n 长度是否不为0、-z 长度是否为0
string1="soccer"
string2=''

if [ -n $string1 ]
then
    echo "The string '$string1' is NOT empty."
else
    echo "The string '$string1' IS empty."
fi

if [ -z $string2 ]
then
    echo "The string '$string2' IS empty."
else    
    echo "The string '$string2' is NOT empty"
fi

if [ -z $string3 ]
then 
    echo "The string '$string2' IS empty."
else    
    echo "The string '$string2' is NOT empty"
fi 
# output:
lxc@Lxc:~/scripts/ch12$ ./variable_content_eval.sh 
The string 'soccer' is NOT empty.
The string '' IS empty.
The string '' IS empty.
```

> **警告：** 空变量和未初始化的变量会对shell脚本测试造成灾难性的影响。如果不确定变量的内容，那么最好在将其用于数值或字符串比较之前先通过 `-n` 或 `-z` 来测试一下变量是否为空。

### 3. 文件比较

|比较|描述|
| :-------: | :------------------------: |
|-d *file*  |检查 *file* 是否存在且为目录|
|-e *file*  |检查 *file* 是否存在|
|-f *file*  |检查 *file* 是否存在且为文件|
|-r *file*  |检查 *file* 是否存在且可读|
|-s *file*  |检查 *file* 是否存在且非空|
|-w *file*  |检查 *file* 是否存在且可写|
|-x *file*  |检查 *file* 是否存在且可执行|
|-O *file*  |检查 *file* 是否存在且属当前用户所有|
|-G *file*  |检查 *file* 是否存在且默认组与当前用户相同|
|*file1* -nt *file2* |检查 *file1* 是否比 *file2* 新|
|*file1* -ot *file2* |检查 *file1* 是否比 *file2* 旧|

#### *1. 检查目录*

[jump_point.sh](./jump_point.sh)

```bash
#!/bin/bash
# Look before you leap
#
jump_directory=/home/Torfa
#
if [ -d $jump_directory ]
then
     echo "The $jump_directory directory exists."
     cd $jump_directory
     ls 
else
     echo "The $jump_directory directory does NOT exist."
fi
```

#### *2. 检查对象是否存在*

`-e` 允许在使用文件或目录前先检查其是否存在：

[update_file.sh](./update_file.sh)

```bash
#!/bin/bash
# Check if either a directory or file exists
#
location=$HOME
file_name="sentinel"
#
if [ -d $location ]
then
     echo "OK on the $location directory"
     echo "Now checking on the file, $file_name..."
     if [ -e $location/$file_name ]
     then
          echo "OK on the file, $file_name."
          echo "Updating file's contents."
          date >> $location/$file_name
     #
     else
          echo "File, $location/$file_name, does NOT exist."
          echo "Nothing to update."
     fi
#
else
     echo "Directory, $location, does NOT exist."
     echo "Nothing to update."
fi
```

#### *3. 检查文件*

`-e` 测试可用于文件和目录。如果要确定指定对象为文件，那就必须使用 `-f` 测试：

[dir-or-file.sh](./dir-or-file.sh)

```bash
#!/bin/bash
# Check if object exists and is a directory or a file
#
object_name=$HOME/lxc
echo
echo "The object being checked: $object_name"
echo
#
if [ -e $object_name ]
then
     echo "The object, $object_name, does exist,"
     #
     if [ -f $object_name ]
     then
          echo "and $object_name is a file."
     #
     else
          echo "and $object_name is a directory."
     fi
#
else
     echo "The object, $object_name, does NOT exist."
fi
```

#### *4. 检查是否可读*

[can-i-read-it.sh](./can-I-read-it.sh)

#### *5. 检查空文件*

[is-it-empty.sh](./is-it-empty.sh)

#### *6. 检查是否可写*

[can-i-write-to-it.sh](./can-I-write-to-it.sh)

#### *7. 检查文件是否可以执行*

[can-i-run-it.sh](./can-I-run-it.sh)

#### *8. 检查所有权*

[do-i-own-it.sh](./do-I-own-it.sh)

#### *9. 检查默认属组关系*

`-G` 测试可以检查文件的属组，如果与用户的默认组匹配，则测试成功。`-G` 只会检查默认组，而非用户所属的所有组。

[check-default-group.sh](./check_default_group.sh)

#### *10. 检查文件日期*

[check_file_dates.sh](./check_file_dates.sh)

`-nt` 与 `-ot` 选项都不会检查文件是否存在，即在文件不存在的情况下，该选项会得出错误的结果，所以，在使用时需要确保文件已经存在.

## 12.5 复合条件测试

`if-then`语句允许使用布尔逻辑将测试条件组合起来。可以使用以下两种布尔运算符。

- ```[ condition1 ] && [ condition2 ]```
- ```[ condition1 ] || [ condition2 ]```

*例如：*

[AndBoolean.sh](./AndBoolean.sh)

```bash
if [ -d $HOME ] && [ -w $HOME/newfile ]
then
    echo "The file $HOME/newfile exists and you can write to it"
# 
else
    echo "You cannot write to the file."
# 
fi
```

## 12.6 *if-then* 的高级特性

bash shell 还提供了3个可在 `if-then` 语句中使用的高级特性。

- 在子shell中执行命令的 `单括号`
- 用于数学表达式的 `双括号`
- 用于高级字符串处理功能的 `双方括号`

### 1. *使用单括号*

单括号允许在 `if` 语句中使用子shell（子shell的用法参见第5章）。  

*命令格式:*

```bash
(command)
```

在bash shell执行 *command* 之前，会先创建一个子shell，然后在其中执行命令。如果命令成功结束，则退出状态码（参见第11章）会被设为0，`then` 部分的命令就会被执行。如果命令的退出状态码不为0，则不执行 `then` 部分的命令。

*例如：*

[SingleParentheses.sh](./SingleParentheses.sh) [SingleParenthese_b.sh](./SingleParentheses_b.sh)

```bash
echo $BASH_SUBSHELL
if ( echo $BASH_SUBSHELL )
then
    echo "The Subshell command operated successfully."
else
    echo "The Subshell command NOT successful."
fi
# output: 
# 0 
# 1 
# The Subshell command operated successfully.
```

当脚本第一次（在 `if` 语句之前）执行 `echo $BASH_SUBSHELL` 命令时，是在当前shell中完成的。该命令会输出0，表明没有使用子shell（`$BASH_SUBSHELL` 环境变量参见第5章）。在 `if` 语句内，脚本在子shell中执行 `echo $BASH_SUBSHELL` 命令，该命令输出1，表明使用了子shell。子shell操作成功，接下来是执行 `then` 部分的命令。

> 注意：在`if test`语句中使用`进程列表`(参见第5章)时，哪怕进程列表中除最后一个命令之外的命令全都失败，即只有进程列表中最后一个命令执行成功，子shell仍会将退出码设置为0.

### 2. ***使用双括号***

**双括号** 命令允许在比较过程中使用高级数学表达式。`test` 命令在进行比较的时候只能使用简单的算数操作。双括号命令提供了更多的数学符号，这些符号对有过其他编程语言经验的程序员并不陌生。

*命令格式：*

```bash
(( expression ))
```

*例如：*

[DoubleParentheses.sh](./DoubleParentheses.sh)

```bash
#
var1=10
#
if (($var1 ** 2 > 90)); then
    ((var2 = $var1 ** 2))
    echo "The square of $var1 = $var2,"
    echo "which is greater than 90."
fi
# output:
# lxc@Lxc:~/scripts/ch12$ ./DoubleParentheses.sh 
# The square of 10 = 100,
# which is greater than 90.
```

以下列出双括号中可用的部分运算符。

|符号|描述|
| :-----: | :-----:|    
|*val++* |后增|
|*val--* |后减|
|*++val* |先增|
|*--val* |先减|
|!|逻辑求反|
|~|位求反 |
|**|幂运算  |
|<<|左位移  |
|\>>|右位移  |
|&|位布尔AND|
|\||位布尔OR|
|&&|逻辑AND|
|\|\||逻辑OR|

注意在双括号中大于小于号不用转义。

### 3. ***使用双方括号***

**双方括号** 命令提供了针对字符串比较的高级特性。

*命令格式:*

```bash
[[ expression ]]
```

*expression* 可以使用 `test` 命令中的标准字符串比较。除此之外，它还提供了 `test` 命令所不具备的另一个特性： **模式匹配** 。  
在进行模式匹配时，可以定义通配符或正则表达式（参见 [第20章](../ch20/README.md)）来匹配字符串。  
注意，当在双方括号内使用 `==` 运算符或 `!=` 运算符时，运算符的右侧被视为通配符。如果使用的是 `~=` 运算符，则运算符右侧被视为POSIX扩展正则表达式。

[DoubleBrackets.sh](./DoubleBrackets.sh)

```bash
# DoubleBrackets.sh 
if [[ $BASH_VERSION == 5.* ]]
then
    echo "You are using bash shell 5 series."
fi
```

> **注意：** 双方括号在bash shell中运作良好。不过要小心，不是所有的shell的支持双方括号。

## 12.7 *case* 命令

*命令格式:*

```bash
case variable in
pattern1 | pattern2) commands1;;
pattern3) commands2;;
*) default commands;;
esac
```

*来个例子：*

[ShortCase.sh](./ShortCase.sh)

```bash
#!/bin/bash
# Using a short case statement.
#
case $USER in
rich | christine)
    echo "Welcome $USER"
    echo "Please enjoy your visit."
    ;;
barbara | lxc)
    echo "Hi, there, $USER"
    echo "We are glad you could join us."
    ;;
testing)
    echo "Please log out when done with test."
    ;;
*)
    echo "Sorry, you are not allowed here."
    ;;
esac
```

## 8. 实战演练

一个脚本，该脚本会将本章的结构化命令付诸实践，确定当前系统中可用的软件包管理器，以已安装的软件包管理器为指导，猜测当前系统是基于哪个Linux发行版。

[PackageMgrCheck.sh](./PackageMgrCheck.sh)

脚本中用到了输出重定向。`which` 命令的标准输出和标准错误输出都通过 `&>` 符号重定向到 */dev/null*，这个地方被幽默地称为黑洞，因为被送往这里的东西从来都是有来无回。[第15章](../ch15/README.md#2-重定向错误消息和正常输出) 介绍了错误重定向。