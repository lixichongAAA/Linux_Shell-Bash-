# ch14 处理用户输入

---

bash shell提供了一些不同的方法来从用户处获取数据，包括命令行参数（添加在命令行后的数据）、命令行选项（可改变命令行为的单个字母）以及从键盘读取输入。

## 1. 传递参数

向shell脚本传递参数的最基本方法是使用**命令行参数**。格式如下：

```bash
./addem 10 30
```

### ***1. 读取参数***

bash shell会将所有的命令行参数都指派给称作 **位置参数** 的特殊变量。这也包括shell脚本名称。位置变量的名称都是标准数字：`$0` 对应脚本名，`$1` 对应第一个命令行参数，`$2`对应第二个，第9个之后，必须在变量名两侧加上花括号用于界定名称，例如 `${10}` 表示第10个位置参数。

*例如：*

[stringparam.sh](./stringparam.sh)

```bash
#!/bin/bash
# Usint the command-line string parameter
# 
echo Hello $1, glad to meet you.
exit
```

参数之间是以空格分隔的，如果你的命令行参数中包含空格，需以引号（单或者双）包围：

```bash
./stringparam 'big world'
# output: Hello big world, glad to meet you.
```

### ***2. 读取脚本名***

使用位置变量 `$0` 来获取运行中的shell脚本名。

如果你使用另一个命令来运行shell脚本，则命令名和脚本名会混在一起，出现在位置变量`$0`中：
当然你在脚本所在目录以 `bash 脚本名` 的命令运行脚本，`$0` 中是只有脚本名的。

```bash
bash position0.sh
# output: This script name is position0.sh.

./position0.sh 
# output This script name is ./position0.sh.
```
如果你运行脚本时使用的是绝对路径，那么位置变量 `$0` 就会包含整个路径

如果你编写脚本只打算使用脚本名，可以使用`basename`命令：

[posbasename.sh](./posbasename.sh)

```bash
#!/bin/bash
# Using basename with the $0 command-line parameter.
# 
name=$( basename $0 )
# 
echo The script name is $name
exit
# output: The script name is posbasename.sh
```

### ***3. 参数测试***

当脚本认为位置变量中应该有数据，而实际根本没有的时候，脚本很可能会产生错误消息。这种编写脚本的方法并不可取。在使用位置变量之前一定要检查是否为空：

[checkpositional1.sh](./checkposition1.sh)

```bash
#!/bin/bash
# Using one command-line parameter.
# 
if [ -n "$1" ]
then    
    factorial=1
    for (( number = 1; number <= $1; number++ ))
    do
        factorial=$[ $factorial * $number ]
    done
    echo "The factorial of $1 is $factorial."
else
    echo "You did not provide a parameter."
fi
exit
```

上述例子使用了 `-n` 测试命令行参数 `$1` 是否为空。

## 2. 特殊参数变量

在bash shell中有一些跟踪命令行参数的特殊变量。

### ***1. 参数统计***

特殊变量`$#`含有脚本运行时携带的命令行参数的个数。

*例如：*
[counteparameters.sh](./countparameters.sh)

```bash
#!/bin/bash
# Counting command-line parameters
#
if [ $# -eq 1 ]; then
    fragment="parameter was"
else
    fragment="parameter were"
fi
echo $# $fragment supplied.
exit
```
你可能认为如果`$#`变量含有命令行参数的总数，那么变量`${$#}`应该就代表最后一个位置变量了。实则不然，想使用最后一个位置变量，必须将花括号内的`$`换成`!`（很奇怪。。可能因为实现的原因吧）。

[goodlastparametest.sh](./goodlastparamtest.sh)

```bash
#!/bin/bash
# Testing grabbing the last parameter
#
echo The number of parameters is $#
echo The last parameter is ${!#}
exit
```
需要注意的是，当命令行中没有任何参数时，`$#`的值即为0，但`${!#}`会返回命令行中的脚本名。

### ***2. 获取所有数据***

`$@` 和 `$*` 变量都包含里所有的命令行参数。

**区别**：
- 当`$*`出现在双引号内时，会被扩展成由多个命令行参数组成的单个单词，每个参数之间以IFS变量值的第一个字符分隔，也就是说，\$*会被扩展为 "\$1c\$2c..."（其中c是IFS变量值的第一个字符）。
- 当`$@`出现在双引号时，其所包含的各个命令行参数会被扩展成为独立的单词，也就是说"\$@"会被扩展为"\$1""\$2"...。

*例如：*
[grabdisplayallparams.sh](./grabdisplayallparams.sh)

```bash
#!/bin/bash
# Exploring different methods for grabbing all the parameters.
# 
echo
echo "Using the \$* method: $*"
count=1
for param in "$*"
do
    echo "\$* Parameter #$count = $param"
    count=$[ $count + 1 ]
done
# 
echo
echo "using the \$@ method: $@"
count=1
for param in "$@"
do
    echo "\$@ Parameter #$count = $param"
    count=$[ $count + 1 ]
done
echo
exit
# ./grabdisplayallparams.sh alpha beta charlie delta
# ouput:

# Using the $* method: alpha beta charlie delta
# $* Parameter #1 = alpha beta charlie delta

# using the $@ method: alpha beta charlie delta
# $@ Parameter #1 = alpha
# $@ Parameter #2 = beta
# $@ Parameter #3 = charlie
# $@ Parameter #4 = delta
```

## 3. 移动参数

`shift`命令默认情况下会将每个位置的变量值都向左移动一个位置。因此，变量$3会被移入\$2，\$2会被移入\$1，\$1会被移出，如果某个参数被移出，那么它的值就被丢弃了，无法再恢复。

*例如：*

[shiftparams.sh](./shiftparams.sh)

```bash
#!/bin/bash
# Shifting through the parameters
# 
echo
echo "Using the shift method: "
count=1
while [ -n "$1" ]
do
    echo "Parameter #$count = $1"
    count=$[ $count + 1 ]
    shift
done
echo
```

当然，可以给`shift`命令提供一个参数，指明要移动的位置数：

[bigshiftparams.sh](./bigshiftparams.sh)

```bash
#!/bin/bash
# Shifting mulitiple positions through the parameters
#
echo 
echo "The original parameters: $*"
echo "Now shifting 2..."
shift 2
echo "Here's the new first parameter: $1"
echo
exit
```

## 4. 处理选项

**选项** 是在连字符之后出现的字母（还有以双连字符起始的，后跟字符串的 **长选项** ），能够改变命令的行为。
**命令行参数** 是在脚本名之后出现的各个单词，其中以连字符（-）或双连字符（--）起始的参数，因其能改变命令的行为，所以称作 **命令行选项**。所以，命令行选项是一种特殊形式的命令行参数。

### 1. 查找选项

#### ***1. 处理简单选项***

*上个例子吧：*

[extractoptions.sh](./extractoptions.sh)

```bash
#!/bin/bash
# Extract command-line options.
# 

while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option." ;;
    -b) echo "Found the -b option." ;;
    -c) echo "Found the -c option." ;;
    *) echo "$1 is not an options.";;
    esac
    shift

done
echo
exit
# ./extractoptions.sh -a -b -c -d 
# output:
# Found the -a option.
# Found the -b option.
# Found the -c option.
# -d is not an options.
```

#### ***2. 处理参数和选项***

在Linux中使用双连字符将 **选项** 与 **参数** 分开，该字符告诉脚本 *选项* 何时结束，*参数* 何时开始。

*例如：*

[extractoptionsparams.sh](./extractoptionsparams.sh)

```bash
#!/bin/bash
# Extract command-line options and parameters.
# 
echo
while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option.";;
    -b) echo "Found the -b option.";;
    -c) echo "Found the -c option.";;
    --) shift
        break;;
    *) echo "'$1' is not an option";;
    esac
    shift
done
echo
count=1
for param in $@
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
echo
exit
# ./extractoptionsparams.sh -a -b -c -- test1 test2 test3
# output:
# Found the -a option.
# Found the -b option.
# Found the -c option.

# Parameter #1: test1
# Parameter #2: test2
# Parameter #3: test3
```

#### ***3. 处理含值的选项***

有些选项需要一个额外参数值。像下面这样：

```bash
./testing.sh -a param1 -b -c -d param2
```

[extractoptionsvalues.sh](./extractoptionsparams.sh)

```bash
#!/bin/bash
# Extract command-line options and values
# 
echo
while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option";;
    -b) param=$2
        echo "Found the -b option with parameter value $param"
        shift;;
    -c) echo "Found the -c options";;
    --) shift
        break;;
    *) echo "$1 is not an options";;
    esac
    shift
done
# 
echo
count=1
for param in $@
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
exit
# ./extractoptionsvalues.sh -a -b Bvalues -c
# output:

# Found the -a option
# Found the -b option with parameter value Bvalues
# Found the -c options
```

有时，我们需要合并选项，像下面这样：

```bash
./testing.sh -ab Bvalues -cd
```
我们使用下面的方法。

### 2. 使用`getopt`命令

#### ***1. 命令格式***

```bash
getopt optstring parameters
```
其中，*optstring* 定义了有效的命令行选项字母，以及哪些选项字母需要参数值。如果 *optstring* 未包含你指定的选项，则在默认情况下，`getopt` 命令会产生一条错误消息。如果想忽略这条消息，可以使用 `getopt` 的 `-q` 选项。

首先，在 *optstring* 中列出脚本中用到的每个命令行选项字母。然后，在每个需要参数值的选项字母后面加一个冒号。`getopt`命令会基于你定义的 *optstring* 解析提供的参数。

*例如：*

```bash
getopt ab:cd -a -b Bvalue -cde test1 test2
# output:
# getopt: invalid option -- 'e'
# -a -b Bvalue -c -d -- test1 test2
```

#### ***2. 在脚本中使用`getopt`***

要使用 `getopt` 命令生成的格式化版本替换已有的命令行选项和参数。要求助于 `set` 命令。
`set` 命令有一个选项是双连字符(--)，可以将 *位置变量* 的值替换成 `set` 命令所指定的值。

具体做法是，将脚本的命令行参数传给 `getopt` 命令，然后再将 `getopt` 命令的输出传给 `set` 命令，用 `getopt` 格式化的命令行参数来替换原始的命令行参数，如下

```bash
set -- $(getopt -a ab:cd "$@")
```

*例如：*

[extractwithgetopt.sh](./extractwithgetopt.sh)

```bash
#!/bin/bash
# Extract command-line options and values with getopt
# 
set -- $(getopt -q ab:cd "$@")
# 
echo
while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option.";;
    -b) param=$2
        echo "Found the -b option with parameter value $param"
        shift;;
    -c) echo "Found the -c option";;
    --) shift
        break;;
    *) echo "$1 is not an option.";;
    esac
    shift
done
# 
echo
count=1
for param in $@
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
exit
# ./extractwithgetopt.sh -ac -b Bvalue -d test1 test2
# output:
# 
# Found the -a option.
# Found the -c option
# Found the -b option with parameter value 'Bvalue'
# -d is not an option.

# Parameter #1: 'test1'
# Parameter #2: 'test2'
```

`getopt` 命令会使用空格作为参数分隔符，而不是根据引号将二者当作一个参数。在命令行参数中，即便用引号将带有空格的参数包围，也会出现问题。所以，有下面的 `getopts` 命令。

#### ***3. 使用 `getopts` 命令***

- `getopts` 命令是bash shell的内建命令。与 `getopt` 的不同之处在于，`getopt` 在将命令行中的选项和参数处理完后只生成一个输出，而 `getopts` 能够和已有的shell *位置变量* 配合默契。

- `getopts` 每次只处理一个检测到的命令行参数。在处理完所有参数后 `getopts` 命令会退出并返回一个大于0的退出状态码。这使其非常适合用在解析命令行参数的循环中。

`getopts` 的命令格式如下：

```bash
getopts optstring variable
```

- *optstring* 值与 `getopt` 命令中使用的值类似。有效的选项字段会在 *optstring* 中列出，如果选项字母要求有参数值，就在其后加一个冒号。如果不想显示错误消息的话，可以在 *optstring* 之前加一个冒号。 `getopts` 命令会将当前参数保存在命令行中定义的 *variable* 中。

- `getopts` 命令要用到两个环境变量。如果选项需要加带参数值，那么 **`OPTARG`** 环境变量保存的就是这个值。
- **`OPTIND`** 环境变量保存着参数列表中 `getopts` 正在处理的参数位置。这样在处理完当前选项之后就能继续处理其他命令行参数了。

*例如：*

[extractwithgetopts.sh](./extractwithgetoptions.sh)

```bash
#!/bin/bash
# Extract command-line options and parameters with getopts
# 
echo
while getopts :ab::cd opt
do
    case "$opt" in
    a) echo "Found the -a option";;
    b) echo "Found the -b option with parameter value $OPTARG";;
    c) echo "Found the -c option";;
    d) echo "Found the -d option";;
    *) echo "Unkonwn option: $opt";;
    esac
done
# 
shift $[ $OPTIND - 1 ]
# 
echo
count=1
for param in "$@"
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
exit
# ./extractoptsparamswithgetopts.sh -ab "Bvalue1 Bvalue2" -de test1 test2
# output:
# 
# Found the -a option
# Found the -b option with parameter value Bvalue1 Bvalue2
# Found the -d option
# Unkonwn option: ?

# Parameter #1: test1
# Parameter #2: test2
```

注意，`getopts` 命令将在命令行找到的所有中未定义的选项统一输出为问号。
至此，你拥有了一个能在所有shell脚本中使用的全功能命令行选项和参数处理工具。

## 5. 选项标准化

在编写shell脚本时，选用那些选项字母以及选项的具体用法，完全由你掌握。
但在Linux中，有些选项字母在某种程度上已经有了标准含义。如果能在shell脚本中支持这些选项，则你的脚本会对用户更友好。
下表列出Linux中一些命令行选项的常用含义。

|选项|描述|
| :--: | :----------:|
|-a|显示所有对象|
|-c|生成计数|
|-d|指定目录|
|-e|扩展对象|
|-f|指定读入数据的文件|
|-h|显示命令的帮助信息|
|-i|忽略文本大小写|
|-l|产生长格式的输出|
|-n|使用非交互模式(批处理)|
|-o|将所有输出重定向至文件|
|-q|以静默模式运行|
|-r|递归处理文件或目录|
|-s|以静默模式运行|
|-v|生成详细输出|
|-x|排除某个对象|
|-y|对所有问题回答yes|


## 6. 获取用户输入

有时候脚本需要一些交互性。你可能想在脚本运行期间询问用户并等待用户回答。

### ***1. 基本的读取***

`read` 命令从标准输入（键盘）或另一个文件描述符中接受输入。获取输入后，`read` 命令会将数据存入变量。

*例如：*

[askname.sh](./askname.sh)

```bash
#!/bin/bash
# Using the read command
# 
echo -n "Enter your name: "
read name
echo "Hello $name, welcome to my script."
exit
# echo 的 -n 选项是不输出尾随换行符
# ./askname.sh 
# output:
# Enter your name: l xc
# Hello l xc, welcome to my script.
```

`read` 命令也提供了 `-p` 选项，允许直接指定提示符：

[askage.sh](./askage.sh)

```bash
#!/bin/bash
# Using the read command with the -p option
# 
read -p "Please enter your age: " age
days=$[ $age * 365 ]
echo "That means you are over $days days old!"
exit
```

- 在第一个例子中输入姓名时，`read` 命令会将姓氏和名字（两者以空格分开了, 如果你在该例中输入以引号包围的以空格分隔的字符串的话，那么最终的 *name* 变量中也会保存引号）保存在同一个变量中。
- `read` 命令会将提示符后输入的所有数据分配给单个变量。如果指定多个变量，则输入的每个数据值都会分配给列表中的下一个变量。如果变量数量不够，那么剩下的数据就全都分配给最后一个变量：

[askfirstlastname.sh](./askfirstlastname.sh)

```bash
#!/bin/bash
# Using the read command for multiple variables.
# 
read -p "Enter your first and last name: " first last
echo "Checking data for $last, $first..."
exit
# ./askfirstlastname.sh 
# output:
# Enter your first and last name: l xc yyds
# Checking data for xc yyds, l...
```

也可以在 `read` 命令中不指定任何变量，这样 `read` 命令便会将接收到的所有数据都放进特殊环境变量`REPLY` 中：

[asknamereply.sh](./asknamereply.sh)

```bash
#!/bin/bash
# Using the read command with REPLY variable
#
read -p "Enter your name: "
echo
echo "Hello $REPLY, welcome to my script."
exit
# ./asknamereply.sh 
# output:
# Enter your name: l xc
# 
# Hello l xc, welcome to my script.
```

`REPLY` 环境变量包含输入的所有数据，其可以在shell脚本中像其他变量一样使用。

### ***2. 超时***

你可以使用 `-t` 选项来指定一个定时器。`-t` 选项会指定 `read` 命令等待输入的秒数。如果计时器超时，则 `read` 命令会返回非0的退出状态码：

[asknametimed.sh](./asknametimed.sh)

```bash
#!/bin/bash
# Using the read command with a timer
# 
if read -t 5 -p "Enter your name: " name
then
    echo "Hello $name, welcome to my script."
else
    echo
    echo "Sorry, no longer waiting for time."
fi
exit
```

你也可以通过 `-n` 选项让 `read` 命令统计输入的字符数。当字符数达到预设值时，就自动退出，将已输入的数据赋给变量：

[continueornot.sh](./continueornot.sh)

```bash
#!/bin/bash
# Using the read command for one character
# 
read -n 1 -p "Do you want to continue [Y/N]? " answer
# 
case $answer in
Y | y) 
    echo
    echo "Okay. Continue on...";;
N | n) 
    echo
    echo "Okay. Goodbay"
    exit;;
esac
echo "This is the end of the script."
exit
```

本例中使用了 `-n` 选项和数值1，告诉 `read` 命令在接收到单个字符后退出。只要按下单个字符进行应答， `read` 命令就会接受输入并将其传给变量，无须按Enter键。

### ***3. 无显示读取***

有时你需要从脚本用户处得到输入，但又不想在屏幕上显示输入信息。典型的例子就是输入密码，但除此之外还有很多种需要隐藏的数据。
`-s` 选项可以避免在 `read` 命令中输入的数据出现在屏幕上（其实数据还是会显示，只不过 `read` 命令将文本颜色设成了跟背景色一样）。

*来个例子：*

[askpassword.sh](./askpassword.sh)

```bash
#!/bin/bash
# Hiding input date
# 
read -s -p "Enter your password:" passwd
echo
echo "Your password is $passwd"
exit
# ./askpassword.sh 
# output:
# Enter your password:
# Your password is 66666
```

### ***4. 从文件中读取***

我们也可以使用 `read` 命令读取文件。每次调用 `read` 命令都会从指定文件中读取一行文本。当文件中没有内容可读时， `read` 命令会退出并返回非0的状态码。

其中麻烦的地方是将文件数据传给 `read` 命令。最常见的方法是对文件使用 `cat` 命令，将结果通过管道直接传给含有 `read` 命令的 `while` 明令。 来个例子：

[readfile.sh](./readfile.sh)

```bash
#!/bin/bash
# Using the read command to read a file
# 
count=1
cat $HOME/scripts/ch14/test.txt | while read line
do
    echo "Line $count: $line"
    count=$[ $count + 1 ]
done
echo "Finished processing the file."
exit
```

`while` 循环会持续通过 `read` 命令处理文件的各行，直到 `read` 命令以非0状态码退出。