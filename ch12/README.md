# ch12结构化命令

## 12.1 使用 *if-then* 语句
语句格式:
```bash
if command
then
    commands
fi
```
- bash shell的`if`语句会运行`if`之后的命令。如果该命令的退出状态码为0（命令成功运行），那么位于
`then`部分的命令就会被执行。若为其他值，则不会被执行

## 12.2 *if-then-else* 语句

语句格式:
```bash
if command
then    
    commands
else
    commands
fi
```

## 12.3 嵌套 *if* 语句
语句格式:
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

## 12.4 *test*命令
语句格式:
```bash
if test condition
then
    commands
fi
```
- `if-then`语句不能测试命令退出状态码之外的条件。
- 我们可以使用`test`测试不同条件，如果`test`命令中列出的条件成立，那么`test`命令就会退出并
返回退出状态码 0 。这样`if-then`语句的工作方式就和其他编程语言中的`if-then`语句差不多了。

例如：
```bash
my_variable="Full"
# 这里my_variable变量非空，所以test会返回0.否则，则会执行else分支
if test $my_variable
then
    echo "The my_variable variable has content and returns a True."
    echo "The my_variable variable content is $my_variable."
else
    echo "The my_variable variable doesn't have content,"
    echo "and return a False."
fi
```

bash shell中提供了另一种 *条件测试* 方式，无须在`if-then`语句中写明`test`命令：
```bash
if [ condition ]
then
    commands
fi
```
> **注意**，第一个方括号之后和第二个方括号之前**必须留有空格**，否则会出错.

1. `test`命令和*测试条件*可以判断3类条件
    - 数值比较
   
    |比较        | 描述          |
    | :-------: | :------------------------: |
    |n1 -eq n2  |检查 *n1* 是否等于 *n2* |
    |n1 -ge n2  | 检查 *n1* 是否大于或等于 *n2* |
    |n1 -gt n2  |检查 *n1* 是否大于 *n2* |
    |n1 -le n2  |检查 *n1* 是否小于或等于 *n2* |
    |n1 -lt n2  |检查 *n1* 是否小于 *n2* |
    |n1 -ne n2  |检查 *n1* 是否不等于 *n2* |
   
    > 注意：对于条件测试。bash shell只能处理整数，尽管可以将浮点值用于某些命令(比如`echo`),
    但它们在条件测试下无法正常工作。
    - 字符串比较

    |比较             | 描述          |
    | :-------:      | :------------------------: |
    |*str1* = *str2* |检查*str1*是否和*str2*相同 |
    |*str1* != *str2*|检查*str1*是否和*str2*不同 |
    |*str1* < *str2* |检查*str1*是否小于*str2* |
    |*str1* > *str2* |检查*str1*是否大于*str2* |
    |-n *str1*       |检查*str1*的长度是否不为0 |
    |-z *str1*       |检查*str1*的长度是否为0 |
   
    > **注意**：在条件测试中大于号和小于号**必须**转义，否则会被shell视为重定向符，将字符串当作文件名.
    > **其次**，大于和小于顺序和`sort`命令采用的比较不同
    > `sort`命令使用的是系统语言环境设置中定义的排序顺序。比较测试中使用的是标准的Unicode顺序，根据每个字符的Unicode编码值来决定排序结果.
    - 文件比较

    |比较        | 描述          |
    | :-------: | :------------------------: |
    |-d *file*  |检查*file*是否存在且为目录|
    |-e *file*  |检查*file*是否存在|
    |-f *file*  |检查*file*是否存在且为文件|
    |-r *file*  |检查*file*是否存在且可读|
    |-s *file*  |检查*file*是否存在且非空|
    |-w *file*  |检查*file*是否存在且可写|
    |-x *file*  |检查*file*是否存在且可执行|
    |-O *file*  |检查*file*是否存在且属当前用户所有|
    |-G *file*  |检查*file*是否存在且默认组与当前用户相同|
    |*file1* -nt *file2* |检查*file1*是否比*file2*新|
    |*file1* -ot *file2* |检查*file1*是否比*file2*旧|
    
    > 注意：`-nt`与`-ot` 选项都不会检查文件是否存在，即在文件不存在的情况下，该选项会得出错误的结果
    所以，在使用时需要确保文件已经存在.

## 12.5 复合条件测试
`if-then`语句允许使用布尔逻辑将测试条件组合起来。可以使用以下两种布尔运算符。
- ```[ condition1 ] && [ condition2 ]```
- ```[ condition1 ] || [ condition2 ]```

例如：

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


## 12.6 `if-then`的高级特性
bash shell 还提供了3个可在`if-then`语句中使用的高级特性
- 在子shell中执行命令的 `单括号`
- 用于数学表达式的 `双括号`
- 用于高级字符串处理功能的 `双方括号`

1. ***使用单括号***
命令格式:
```bash
(command)
```
例如：
```bash
# SingleParenthese.sh
# 在bash shell执行命令之前，会先创建一个子shell，然后在其中执行命令。
echo $BASH_SUBSHELL
if ( echo $BASH_SUBSHELL )
then
    echo "The Subshell command operated successfully."
else
    echo "The Subshell command NOT successful."
fi
# output: 0 
# 1 
# The Subshell command operated successfully.
```
> 注意：在`if test`语句中使用`进程列表`(参见第5章)时，哪怕进程列表中除最后一个命令之外的命令全都失败，
子shell仍会将退出码设置为0.

2.***使用双括号***
命令格式：
```bash
(( expression ))
```
例如：
```bash
#
var1=10
#
if (($var1 ** 2 > 90)); then
    ((var2 = $var1 ** 2))
    echo "The square of $var1 = $var2,"
    echo "which is greater than 90."
fi
# DoubleParenthese.sh
```
双括号命令允许在比较过程中使用高级数学表达式。以下列出双括号中可用的部分运算符。
| 符号     | 描述 |
| :-----: | :-----:|    
|*val++*  |后增   |
|*val--*  |后减   |
|*++val*  |先增   |
|*--val*  | 先减  |
|!        |逻辑求反|
| ~       |位求反 |
|**       |幂运算  |
|<<       |左位移  |
|\>>      |右位移  |
| &       |位布尔AND|
| |       |位布尔OR|
| &&      |逻辑AND|
| ||      |逻辑OR|
> 注意在双括号中大于小于号不用转义

3. ***使用双方括号***
命令格式:
```bash
[[ expression ]]
```
*expression* 可以使用`test`命令中的标准字符转比较。除此之外，他还提供 *模式匹配* 的特性
例如:
```bash
# DoubleBrackets.sh 
if [[ $BASH_VERSION == 5.* ]]
then
    echo "You are using bash shell 5 series."
fi
```

## 12.7 *case* 命令
命令格式:
```bash
case variable in
pattern1 | pattern2) commands1;;
pattern3) commands2;;
*) default commands;;
esac
```
