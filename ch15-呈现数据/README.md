# ch15 呈现数据

本章将演示如何将脚本的输出重定向到Linux系统的不同位置。

## 1. 理解输入输出

到目前位置，你已经知道了两种显示脚本输出的方法。

- 在显示器屏幕上显示输出。
- 将输出重定向到文件。

这两种方法要么将数据全部显示出来，要么什么都不显示。但有时将一部分数据显示在屏幕上，另一部分数据保存到文件中更合适。对此，了解Linux如何处理输入输出有助于将脚本输出送往所需的位置。

### 1. 标准文件描述符

Linux系统会将每个对象当作文件来处理，这包括输入输出。Linux用 **文件描述符** 来标识每个文件对象。文件描述符是一个非负整数，唯一会标识的是会话中打开的文件。每个进程一次最多可以打开 **9** (这个数量并不是固定的)个文件描述符。出于特殊目的，bash shell保留了前 **3** 个文件描述符(0、1和2)。见下表。

|文件描述符|缩写|描述|
| :---: | :-: | :-: |
|0|STDIN|标准输入|
|1|STDOUT|标准输出|
|2|STDERR|标准错误|

#### *1. STDIN*

*STDIN* 文件描述符代表标准输入，于终端界面而言，标准输入就是键盘。在使用输入重定向符（<）时，Linux会用重定向指定的文件替换标准输入文件描述符。于是，命令就会从文件中读取数据，就好像这些数据就是从键盘键入的。

*例如：*

```bash
# 使用 cat 命令来处理STDIN的输入：
$ cat
This is a test
This is a test
This is a second test
This is a second test
# 当在命令行中输入cat命令时，它会从STDIN接受输入。输入一行，cat命令就显示一行。
# 也可以通过输入重定向符强制cat命令接受来自STDIN之外的文件输入:
$ cat < testfile
This is the first line.
This is the second line.
This is the third line.
```

内联输入重定向 **<<** 见[第11章笔记](../ch11/README.md#2-输入重定向)。

#### *2. STDOUT*

*STDOUT* 文件描述符代表shell的标准输出，在终端界面上，标准输出就是显示器。shell的所有输出（包括shell中运行的程序和脚本）都会被送往标准输出。  
可以通过输出重定向符 **>**，将输出重定向到指定的文件，也可以使用 **>>** 将数据追加到某个文件。

*例如：*

```bash
lxc@Lxc:~/scripts/ch15$ ls -l > test2
lxc@Lxc:~/scripts/ch15$ cat test2
总用量 108
-rwxrw-r-- 1 lxc lxc  145 11月  5 14:24 badtest.sh
-rw-rw-r-- 1 lxc lxc  186 11月  5 15:57 members.csv
-rw-rw-r-- 1 lxc lxc  554 11月  5 15:57 members.sql
-rw-rw-r-- 1 lxc lxc 1096 11月  6 18:11 README.md
...省略
lxc@Lxc:~/scripts/ch15$ who >> test2
lxc@Lxc:~/scripts/ch15$ cat test2
总用量 108
-rwxrw-r-- 1 lxc lxc  145 11月  5 14:24 badtest.sh
-rw-rw-r-- 1 lxc lxc  186 11月  5 15:57 members.csv
...省略
lxc      tty2         2023-11-06 18:58 (tty2)
```

shell对于错误消息的处理和普通输出是分开的。因此，当对脚本使用标准输出重定向时，如果脚本产生错误消息，错误消息会被显示在屏幕上，而输出的文件中只有标准输出的消息。

#### *3. STDERR*

*STDERR* 代表shell的标准错误输出。shell或运行在shell的程序和脚本报错时，生成的错误消息都会被送往这个位置。  
**在默认情况下，*STDOUT* 和 *STDERR* 指向同一个地方（屏幕），但 *STDERR* 并不会随着 *STDOUT* 的重定向而发生改变。在使用脚本时，我们常常想改变这种情况**。

### 2. 重定向错误

重定向 *STDERR* 和重定向 *STDOUT* 没太大区别，只要在使用重定向符时指定 *STDERR* 文件描述符就可以了。

#### *1. 只重定向错误*

*STDERR* 的文件描述符为2，可以将该文件描述符索引值放在重定向符号之前，只重定向错误消息。注意，两者必须挨着，否则出错。

```bash
$ ls -al test2 badtestfile 2> test5 #注释，badtestfile文件不存在
-rw-rw-r-- 1 lxc lxc 1589 11月  6 20:04 test2
$ cat test5
ls: 无法访问 'badtestfile': 没有那个文件或目录
# 如你所见，标准输出显示在屏幕上，标准错误输出重定向了到文件中。
```

#### *2. 重定向错误消息和正常输出*

如果想重定向错误消息和正常输出，则必须使用两个重定向符号。你需要在重定向符号之前放上需要重定向的 文件描述符，然后让它们指向用于保存数据的输出文件：

```bash
$ ls -al test2 test5 badtest 2> test6 1> test7 #注释，badtest文件不存在
$ cat test6
ls: 无法访问 'badtest': 没有那个文件或目录
$ cat test7 
-rw-rw-r-- 1 lxc lxc 1589 11月  6 20:04 test2
-rw-rw-r-- 1 lxc lxc   60 11月  6 20:26 test5
# 如你所见，标准错误输出被重定向到 test6 文件，而标准输出被重定向到 test7 文件。
```

你也可以将 *STDOUT* 和 *STDERR* 重定向到同一个文件。为此bash shell提供了特殊的重定向符号 **`&>`** :

```bash
$ ls -al test2 test5 badtest &> test7 #注释，badtest文件不存在
$ cat test7
ls: 无法访问 'badtest': 没有那个文件或目录
-rw-rw-r-- 1 lxc lxc 1589 11月  6 20:04 test2
-rw-rw-r-- 1 lxc lxc   60 11月  6 20:26 test5
# 如你所见，两者均被重定向到test7文件。
```

> 注意，其中的一条错误消息出现的顺序和预想不同。badtest(列出的最后一个文件)的这条错误消息出现在了输出文件的第一行。这是因为为了避免错误消息散落在输出文件中，相较于标准输出，bash shell自动赋予了错误消息更高的优先级。这样，便于你集中浏览错误消息。

## 2. 在脚本中重定向输出

在脚本中重定向输出方法有两种：

- 临时重定向一行
- 永久重定向脚本中的所有命令

#### *1. 临时重定向*

如果你有意在脚本中生成错误消息，可以将单独的一行输出重定向到 *STDERR* 。这只需要使用输出重定向符号将输出重定向到 *STDERR* 文件描述符。在重定向到文件描述符时，必须在文件描述符索引值之前加一个`&`:

```bash
echo "This is an err message" >&2
```

*来个例子:*

[test8.sh](./test8.sh)

```bash
#!/bin/bash
# Testring STDERR messages

echo "This is an error" >&2
echo "This is normal output"
```

如果你向往常一样运行这个脚本，你看不出任何区别：

```bash
./test8.sh 
This is an error
This is normal output
```

这是因为，**默认情况下， *STDOUT* 和 *STDERR* 指向的位置（屏幕）是一样的。** 但是如果你在运行脚本时重定向了 *STDERR* ，那么脚本中所有送往 *STDERR* 的文本都会被重定向。

```bash
./test8.sh 2> test9
This is normal output
$ cat test9 
This is an error
# 符合预期，标准输出显示在屏幕上，标准错误输出出现在test9文件里。
```

#### *2. 永久重定向*

如果脚本中有大量数据需要重定向，那么逐条重定向所有 `echo` 语句就会很烦琐。这时可以使用 `exec` 命令，它会启动一个新shell，并在脚本执行期间重定向某个特定文件描述符。

*例如：*

[test10.sh](./test10.sh)

```bash
#!/bin/bash
# redirecting all output to a file
exec 1> testout

echo "This is a test of redirecting all output"
echo "from a script to another file."
echo "without having to redirect every individual line."
# output:
# ./test10.sh 
# $ cat testout 
# This is a test of redirecting all output
# from a script to another file.
# without having to redirect every individual line.
```

[test11.sh](./test11.sh)

```bash
#!/bin/bash
# Redirecting output to different locations.

exec 2> testerror

echo "This is start of the script."
echo "now redirecting all output to another location."

exec 1> testout

echo "This output should go to the testout file."
echo "but this should go to testerror file" >&2
# output:
# ./test11.sh 
# This is start of the script.
# now redirecting all output to another location.
# $ cat testout 
# This output should go to the testout file.
# $ cat testerror 
# but this should go to testerror file
# 注意观察结果。 在重定向标准输出之前，标准输出是输出在屏幕上的。
```

一旦重定向了 *STDERR* 或者 *STDOUT* 那么就不太容易将其恢复到原先的位置。如果需要在重定向中来回切换，那么请看 [15.4节](./README.md#4-创建自己的重定向)。

## 3. 在脚本中重定向输入

可以使用与重定向 *STDOUT* 和 *STDERR* 相同的方法，将 *STDIN* 从键盘重定向到其他位置。在Linux系统中，`exec` 命令允许将 *STDIN* 重定向为文件：

```bash
exec 0< filname
```

*来个例子：*

[test12.sh](./test12.sh)

```bash
#!/bin/bash
# redirecting file input
 
exec 0< testfile
count=1
 
while read line
do
   echo "Line #$count: $line"
   count=$[ $count + 1 ]
done
# output:
# ./test12.sh 
# Line #1: This is the first line.
# Line #2: This is the second line.
# Line #3: This is the third line.
```

这是从日志文件中读取并处理数据最简单的方法。

## 4. 创建自己的重定向

前文提到过，在shell中可以打开9个文件描述符。替代性文件描述符从3到8共6个，均可用作输入或输出重定向。这些文件描述符中的任意一个都可以分配给文件并用在脚本中。

#### *1. 创建输出文件描述符*

可以用 `exec` 命令分配用于输出的文件描述符。和标准的文件描述符一样，一旦将替代性文件描述符指向文件，此重定向就会一直生效，直至重新分配。

*来个例子吧:*

[test13](./test13.sh)

```bash
#!/bin/bash
# Using a alternative file descriptor

exec 3> test13out

echo "This should display on monitor"
echo "and this should be stored in the file" >&3
echo "Then this should be back on the monitor."
# output:
# ./test13.sh 
# This should display on monitor
# Then this should be back on the monitor. 
# $ cat test13out 
# and this should be stored in the file
```

当然你也可以不创建新文件，而是使用 `exec` 命令将数据追加到现有文件：

```bash
exec 3>>test13out
```

#### *2. 重定向文件描述符*

有一个技巧可以帮助你恢复已重定向的文件描述符。你可以将另一个文件描述符分配给标准文件描述符，反之亦可。这意味着可以将 *STDOUT* 的原先位置先重定向到另一个文件描述符，然后再利用该文件描述符恢复 *STDOUT*。

*来个例子：*

[test14.sh](./test14.sh)

```bash
#!/bin/bash
# storing STDOUT, then coming back to it

exec 3>&1
exec 1>test14out

echo "This should store in the output file."
echo "alone with this line."

exec 1>&3

echo "Now thing should be back normal."
# output:
# ./test14.sh 
# Now thing should be back normal.
# $ cat test14out 
# This should store in the output file.
# alone with this line.
# 我们先将3重定向到了1，这意味着任何送往文件描述符3的输出都会出现在屏幕上，
# 然后我们将标准输出重定向到了我们需要的文件中，
# 所以下面的两句echo的输出都出现在test14out文件中，
# 随后我们将1重定向到3（3现在是标准输出），所以后续的echo又输出在了屏幕上（标准输出）
```

#### *3. 创建输入文件描述符*

可以采用和重定向输出文件描述符同样的办法来重定向输入文件描述符。在重定向到文件之前，先将 *STDIN* 指向的位置保存到另一个文件描述符，然后在读取完文件之后将 *STDIN* 恢复到原先的位置。

*来个例子：*

[test15.sh](./test15.sh)

```bash
#!/bin/bash
# redirecting input file descriptors.

exec 6<&0
exec 0<testfile

count=0
while read line; do
    echo "Line #$count: $line"
    count=$(($count + 1))
done

exec 0<&6
read -p "Are you done now?" answer
case $answer in
Y | y) echo "GoodBye" ;;
N | n) echo "Sorry, this is the end." ;;
esac
# output:
# ./test15.sh 
# Line #0: This is the first line.
# Line #1: This is the second line.
# Line #2: This is the third line.
# Are you done now?y
# GoodBye
```

#### *4. 创建读/写文件描述符*

你可以打开单个文件描述符兼做输入和输出，这样就能用同一个文件描述符对文件进行读和写两种操作了。  
不过，在使用这种方法时要小心。由于对同一个文件进行读和写两种操作，因此shell会维护一个内部指针，指明文件的当前位置。任何读或者写都会从文件指针上次的位置开始。如果粗心的话，会产生一些意外的结果。

[test16.sh](./test16.sh)

```bash
#!/bin/bash
# testing input/output file descriptor

exec 3<> testfile

read line <&3
echo "Read line: $line"
echo "This is a test line" >&3
# output:
# $cat testfile
# This is the first line.
# This is the second line.
# This is the third line.
# $ ./test16.sh 
# Read line: This is the first line.
# $ cat testfile 
# This is the first line.
# This is a test line
# ine.
# This is the third line.
# 注意testfile文件内容的修改。read 命令读取了第一行数据，这使得文件指针指向了第二行数据的第一个字符
# 当echo语句将数据输出到文件时，会将数据写入文件指针的当前位置，覆盖该位置上已有的数据。
```

#### *5. 关闭文件描述符*

如果创建了新的输入/输出文件描述符，那么shell会在脚本退出时自动将其关闭。然而在一些情况下，我们需要在脚本结束前手动关闭文件描述符。  
要关闭文件描述符，只需将其重定向到特殊符号 `&-` 即可。例如我想关闭文件描述符3：

```bash
exec 3>&-
```

*来个例子：*

[badtest.sh](./badtest.sh)

```bash
#!/bin/bash
# testing closing file descriptors

exec 3> test17file

echo "This is a test line of data" >&3

exec 3>&-

echo "This won't work" >&3
# output:
# $./badtest.sh 
# ./badtest.sh: 行 10: 3: 错误的文件描述符
# 因为文件描述符3已经关闭，所以报错。
```

> - 一旦关闭了文件描述符，就不能再脚本中向其写入任何数据，否则shell会发出错误消息。
> - 在关闭文件描述符时还要注意另一件事。如果随后你在脚本中又打开了同一个输出文件，那么shell就会用一个新文件来替换已有文件。这意味着如果你输出数据，他就会覆盖已有文件。

[test17.sh](./test17.sh)

```bash
#!/bin/bash
# testing closing file descriptors

exec 3> test17file
echo "This is a test line of data" >&3
exec 3>&-

cat test17file

exec 3>test17file
echo "This'll be bad" >&3

cat test17file
# output:
# ./test17.sh 
# This is a test line of data
# This'll be bad
# 在向test17file文件发送字符串并关闭该文件描述符之后，脚本使用cat命令显示文件内容。
# 到这一步，一切都还好。
# 接下来，脚本重新打开了该输出文件并向它发送了另一个字符串。
# 再显示文件内容的时候，你就只能看到第二个字符串了。shell覆盖了原来的输出文件。
```

## 5. 列出打开的文件描述符

能用的文件描述符只有9个，你可能会觉得没有什么复杂的。但有时要记住哪个文件描述符被重定向到了哪里就没那么容易了。为了帮你厘清条理，bash shell提供了 `lsof`（**l**i**s**t **o**pened **f**ile）命令。
`lsof` 命令会列出整个Linux系统打开的所有文件描述符，这包括所有后台进程以及登录用户打开的文件。  
有大量的命令行参数可以过滤 `lsof` 命令的输出。最常用的选项是 `-p` 和 `-d` ，前者允许指定进程ID（PID），后者允许指定要显示的文件描述符编号（多个编号之间以逗号隔开）。  
要想知道当前进程的PID。可以使用特殊环境变量 `$$`（shell会将其设为当前PID）。`-a` 选项可用于对另外两个选项的结果执行AND（取交集）运算。

```bash
lsof -a -p $$ -d 0,1,2
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash    9454  lxc    0u   CHR  136,1      0t0    4 /dev/pts/1
bash    9454  lxc    1u   CHR  136,1      0t0    4 /dev/pts/1
bash    9454  lxc    2u   CHR  136,1      0t0    4 /dev/pts/1
# 显示了当前进程的默认文件描述符。
```

`lsof` 的默认输出中包含多列信息，含义如下表所示：

|列|描述|
| :--------: | :---------------------------------:|
|COMMAND|进程对应的命令名的前9个字符|
|PID|进程的PID|
|USER|进程属主的登录名|
|FD|文件描述符编号以及访问类型(*r* 代表可读，*w* 代表可写，*u* 代表读/写)|
|TYPE|文件的类型（*CHR* 代表字符型，*BLK* 代表块型，*DIR* 代表目录，*REG* 代表常规文件）|
|DEVICE|设备好（主设备号和从设备号）|
|SIZE|如果有的话，代表文件的大小|
|NODE|本地文件的节点号|
|NAME|文件名|

与 *STDIN*、*STDOUT* 和 *STDERR* 关联的文件类型是字符型，因为这三个文件描述符都指向终端，所以输出文件名就是终端的设备名。这3个标准文件描述符都支持读和写（尽管向 *STDIN* 写数据以及从 *STDOUT* 读数据看起来有点奇怪）。

[test18.sh](./test18.sh)

```bash
#!/bin/bash
# testing lsof with file descriptors

exec 3> test18file1
exec 6> test18file2
exec 7< testfile

lsof -a -p $$ -d 0,1,2,3,6,7
# output:
 ./test18.sh 
COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
test18.sh 10474  lxc    0u   CHR  136,1      0t0       4 /dev/pts/1
test18.sh 10474  lxc    1u   CHR  136,1      0t0       4 /dev/pts/1
test18.sh 10474  lxc    2u   CHR  136,1      0t0       4 /dev/pts/1
test18.sh 10474  lxc    3w   REG  259,8        0 2245976 /home/lxc/scripts/ch15/test18file1
test18.sh 10474  lxc    6w   REG  259,8        0 2245978 /home/lxc/scripts/ch15/test18file2
test18.sh 10474  lxc    7r   REG  259,8       73 2250411 /home/lxc/scripts/ch15/testfile
```

## 6. 抑制命令输出

有时候，你可能不想显示脚本输出。将脚本作为后台进程运行时这很常见（参见[第16章](../ch16/README.md#1-后台模式运行脚本)）。如果在后台运行的脚本出现错误消息，那么shell会将其通过邮件发送给进程属主。这会很麻烦，尤其是当运行的脚本输出很多烦琐的小错误时。  
**要解决这个问题，可以将 *STDERR* 重定向到一个名为`null`文件的特殊文件** (该文件已有讲述，见[第12章](../ch12/README.md#8-实战演练)) 跟它的名字很像，null文件里什么都没有。shell输出到null文件的任何数据都不会被保存，全部会被丢弃。  
在Linux系统中，null文件的位置是 */dev/null* 。重定向到该位置的任何数据都会被丢弃，不再显示。

```bash
$ ls -al > /dev/null
$ cat /dev/null
$
```

这是抑制错误消息出现且无须保存它们的一种方法。  
也可以在输入重定向中将 */dev/null* 作为输入文件。由于 */dev/null* 文件不包含任何内容，因此我们通常用它来快速清除现有文件中的数据，这样就不用删除文件再重新创建了：

```bash
$ cat testfile
This is the first line.
This is the second line.
This is the third line.
$ cat /dev/null > testfile
$ cat testfile
$
# testfile文件仍然存在，但现在是一个空文件。
```

**这是清除日志文件的常用方法，因为日志文件必须时刻等待应用程序操作**

## 7. 使用临时文件

Linux系统有一个专供临时文件使用的特殊目录 */tmp*，其中存放那些不需要永久保留的文件。大多数Linux发行版配置系统在启动时会自动删除 */tmp* 目录的所有文件。  
系统中的任何用户都有权限读写 */tmp* 目录中的文件。这个特性提供了一种创建临时文件的简单方法，而且还无须担心清理工作。  
还有一个专门用于创建临时文件的命令 **`mktemp`**，该命令可以直接在 */tmp* 目录中创建唯一临时文件。所创建的临时文件不使用默认的 *umask*（参见第7章）值。作为临时文件属主，你拥有该文件的读写权限，但其他用户无法访问（当然，root用户除外）。  

### *1. 创建本地临时文件*

在默认情况下，`mktemp` 会在当前目录中创建一个文件。在使用 `mktemp` 命令时，只需指定一个文件名模板即可。模板可以包含任意文本字符，同时在文件名末尾要加上6个`X`:

```bash
mktemp testing.XXXXXX
testing.2x7Ykb
ls -al testing.2x7Ykb 
-rw------- 1 lxc lxc 0 11月  7 17:14 testing.2x7Ykb
```

`mktemp` 命令会任意地将6个 `X` 替换为同等数量的字符，以保证文件名在目录中是唯一的。`mktemp` 命令输出的就是它所创建的文件名。在脚本中使用 `mktemp` 命令时，可以将文件名保存到变量中，这样就能在随后的脚本中引用了：

[test19.sh](./test19.sh)

```bash
#!/bin/bash
# creating and using a temp file

tempfile=$(mktemp test19.XXXXXX)

exec 3>$tempfile

echo "This script writes to temp file $tempfile"

echo "This is the first line" >&3
echo "This is the second line." >&3
echo "This is the third line." >&3
exec 3>&-

echo "Done creating temp file. The contains are:"
cat $tempfile

rm -f $tempfile 2>/dev/null
# output:
#  ./test19.sh 
# This script writes to temp file test19.WHmkCQ
# Done creating temp file. The contains are:
# This is the first line
# This is the second line.
# This is the third line.
```

### *2. 在 /tmp 目录中创建临时文件*

`-t` 选项会强制 `mktemp` 命令在系统的临时目录中创建文件。在使用这个特性时，`mktemp` 命令返回的是所创建的临时文件的完整路径名，而不是文件名。

[test20.sh](./test20.sh)

```bash
#!/bin/bash
# creating a temp file in /tmp

tempfile=$(mktemp -t tmp.XXXXXX)

echo "This is a test file." >$tempfile
echo "This is the second line of the test." >>$tempfile

echo "The temp file is located at: $tempfile"
cat $tempfile
rm -f $tempfile
```

### *3. 创建临时目录*

`-d` 选项会告诉 `mktemp` 命令创建一个临时目录。你可以根据需要使用该目录，比如在其中创建其他临时文件。

[test21.sh](./test21.sh)

```bash
#!/bin/bash
# using a temporary directory

tempdir=$(mktemp -d dir.XXXXXX)
cd $tempdir

tempfile1=$(mktemp temp.XXXXXX)
tempfile2=$(mktemp temp.XXXXXX)

exec 7> $tempfile1
exec 8> $tempfile2

echo "Sending data to directory $tempdir."
echo "This is a test line of data for $tempfile1." >&7
echo "This is a test line of data for $tempfile2." >&8

echo "Done."
```

## 8. 记录消息

有时候我们需要将输出同时送往显示器和文件。与其对输出进行两次重定向，不如使用 **`tee`** 命令。  
`tee` 命令就像是连接管道的T型接头，它能将来自 *STDIN* 的数据同时送往两处。一处是 *STDOUT*，另一处是 `tee` 命令行所指定的文件名。  

> **`tee`** 命令便于将输出同时发往标准输出和日志文件。这样你就可以在屏幕上显示脚本消息的同时将其保存在日志文件中。

*命令格式:*

```bash
tee filename
```

*来个例子：*

```bash
date | tee testfile
2023年 11月 07日 星期二 17:30:43 CST
cat testfile 
2023年 11月 07日 星期二 17:30:43 CST
```

输出出现在了 *STDOUT* 中，同时写入了指定的文件。注意，在默认情况下，`tee` 命令会在每次使用时覆盖指定文件的原先内容。如果想将数据追加到指定文件中，必须使用 `-a` 选项。

```bash
date | tee -a testfile 
2023年 11月 07日 星期二 17:34:00 CST
$ cat testfile 
2023年 11月 07日 星期二 17:33:39 CST
2023年 11月 07日 星期二 17:34:00 CST
```

[test22.sh](./test22.sh)

```bash
#!/bin/bash
# Using the tee command for logging

tempfile=test22file

echo "This is the start of the test." | tee $tempfile
echo "This is the second line of the test." | tee -a $tempfile
echo "This is the end of the test." | tee -a $tempfile
```

## 9. 实战演练

搞个脚本，读取CSV格式的数据文件，输出SQL INSERT语句。

[test23.sh](./test23.sh)

```bash
#!/bin/bash
# read file and create INSERT statements for MYSQL

outfile='members.sql'
IFS=','
while read lname fname address city state zip
do
    cat >> $outfile << EOF
    INSERT INTO members(lname, fname, address, city, state, zip) VALUES ('$lname', '$fname', '$address', '$city', '$state', '$zip');
EOF
done < ${1}
```

脚本中出现了3处重定向操作。`while` 循环使用 `read` 语句从数据文件中读取文本。注意 `done` 语句中出现的重定向符号：

```bash
done < ${1}
```

脚本中另外两处重定向操作出现在同一条语句中：

```bash
cat >> $outfile << EOF
```

这条语句包含一个输出重定向（追加）和一个内联输入重定向（使用EOF字符串作为起止标志）。输出重定向将 `cat` 命令的输出追加到由 `$outfile` 变量指定的文件中，可以这样看这个语句：

```bash
cat >> $outfile
```

`cat` 命令的输入使用内联输入重定向，使用EOF字符串作为起止的标志，或许这样看更清晰一些：

```bash
cat << EOF
INSERT INTO members(lname, fname, address, city, state, zip) VALUES ('$lname', '$fname', '$address', '$city', '$state', '$zip');
EOF
```

不再解释。  

下面是输出：

```bash
lxc@Lxc:~/scripts/ch15$ ./test23.sh members.sql
lxc@Lxc:~/scripts/ch15$
```

当然，运行脚本时，显示器上不会有任何输出。可以在输出文件 `members.sql` 中查看输出。