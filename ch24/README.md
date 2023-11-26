# ch24 编写简单的脚本实用工具

主要解释一下本章四个脚本中用到的一些命令。这几个脚本用到的知识在前文都已经讲过了，所以看懂的话肯定是没难度的。

## 1. 创建按日归档的脚本

[Daily_archive](./Daily_archive.sh)

因为tar归档文件会占用大量的磁盘空间，因此最好压缩一下。这只需加一个 `-z` 选项即可。该选项会使用gzip压缩tar归档文件，由此生成的文件称作 tarball。后缀一般是 `.tar.gz` 或 `.tgz`。

```bash
tar -czf archive.tgz Project/*.* 2>/dev/null
```

在
```bash
if [ -f $filename -o -d $filename]
```
中，`-o` 选项使得只要其中一个测试为真，那么整个 `if` 语句就成立。其他选项见 [第12章](../ch12/README.md#3-文件比较)。

其他可能有助于备份的工具，可以查看 `man -k archive` 和 `man -k copy`。

## 2. 创建按小时归档的脚本

[Hourly_archive.sh](./Hourly_archive.sh)

如果希望文件名总是保留4位小数，则可以将脚本中的 `TIME=$(date +%k%M)` 修改为 `TIME=$(date +%k0%M)`。在 `%k` 后面加入数字0后，所有的单位(single-digit)小时数都会加上一个前导数字0，被填充成两位数字。

## 3. 删除账户

[Delete_User.sh](./Delete_User.sh)

---

`cut` 命令的用法。`cut` 命令在手册中说明的很清楚了，看手册吧。

Print selected parts of lines from each FILE to standard output.
With no FILE, or when FILE is -, read standard input.

`cut` 支持三种选中方式，`-b` 选项以字节为单位进行选中，`-c` 选项以字符为单位选中，`-f` 以字段为单位选中，`cut` 命令默认的字段分隔符为TAB。

Use one, and only one of -b, -c or -f.  Each LIST is made up of one range, or many ranges separated by commas.
Selected  input  is written in the same order that it is read, and is written exactly once.  Each range is oneof:
- N      N'th byte, character or field, counted from 1

- N-     from N'th byte, character or field, to end of line

- N-M    from N'th to M'th (included) byte, character or field

- -M     from first to M'th (included) byte, character or field

来看几个例子：

```bash
lxc@Lxc:~/tt$ cat text1.txt 
echo "Hello World!"
哈哈
lxc@Lxc:~/tt$ cut -b 1 text1.txt 
e
�
lxc@Lxc:~/tt$ cut -b 1-3 text1.txt 
ech
哈
lxc@Lxc:~/tt$ cut -b 1- text1.txt 
echo "Hello World!"
哈哈
lxc@Lxc:~/tt$ cut -b -3 text1.txt 
ech
哈
lxc@Lxc:~/tt$ cut -b 1,3,4 text1.txt 
eho
��
xc@Lxc:~/tt$ cut -d " " -f1 text1.txt 
echo
哈哈
lxc@Lxc:~/tt$ cut -d " " -f2 text1.txt 
"Hello
哈哈
lxc@Lxc:~/tt$ cut -d " " -f1 -s text1.txt 
echo
lxc@Lxc:~/tt$ cut -d " " -f 1- -s --output-delimiter "      " text1.txt 
echo      "Hello      World!"
lxc@Lxc:~/tt$ cut -d "  " -f 1- -s --output-delimiter "      " text1.txt 
cut: 分界符必须是单个字符
请尝试执行 "cut --help" 来获取更多信息。
lxc@Lxc:~/tt$ cat /etc/passwd | grep lxc | cut -d: -f7
/bin/bash
```

`cut` 的 `-s` 选项： do not print lines not containing delimiters

在这个脚本中，

```bash
lxc@Lxc:~/scripts$ echo "Yes" | cut -c1
Y
```

`cut` 命令的 `-c1` 选项可以删除除第一个字符之外的所有内容，即选中第一个字符。

```bash
cut -d: -f7
```

`cut` 命令的 `-d` 选项指定字段分隔符为`:`，`-f7` 选项指定记录中的第七个字段。

---

`xargs` 命令的用法。

`xargs` 命令来自英文词组“extended arguments”的缩写，其功能是用于给其他命令传递参数的过滤器。xargs命令能够处理从标准输入或管道符输入的数据，并将其转换成命令参数，也可以将单行或多行输入的文本转换成其他格式。

```bash
lxc@Lxc:~/tt$ echo "Hello World" | echo 

lxc@Lxc:~/tt$ echo "Hello World" | xargs echo
Hello World
lxc@Lxc:~/tt$ echo "Hello World" | xargs -n 1
Hello
World
lxc@Lxc:~/tt$ echo "Hello#World" | xargs -d "#"
Hello World

lxc@Lxc:~/tt$ echo -n "Hello#World" | xargs -d "#"
Hello World
lxc@Lxc:~/tt$ echo -n "Hello#World" | xargs -d "#" -p
echo Hello World ?...y
Hello World
lxc@Lxc:~/tt$ echo -n "Hello#World" | xargs -d "#" -n 1 -p
echo Hello ?...y
Hello
echo World ?...y
World
lxc@Lxc:~/tt$ echo -n "Hello#World" | xargs -d "#" -n 1 -t
echo Hello 
Hello
echo World 
World
lxc@Lxc:~/tt$ echo -n "hello#world" | xargs -I {} echo {}
hello#world
lxc@Lxc:~/tt$ echo | xargs echo

lxc@Lxc:~/tt$ echo | xargs -r echo
lxc@Lxc:~/tt$ ll
总用量 12
drwxrwxr-x  2 lxc lxc 4096 11月 26 12:56 ./
drwxr-xr-x 55 lxc lxc 4096 11月 26 13:42 ../
-rw-rw-r--  1 lxc lxc   27 11月 26 12:56 text1.txt
-rw-rw-r--  1 lxc lxc    0 11月 26 12:55 text2.txt
-rw-rw-r--  1 lxc lxc    0 11月 26 12:55 text3.txt
lxc@Lxc:~/tt$ vim text1.txt 
lxc@Lxc:~/tt$ cat text1.txt 
lalala
hahaha
heihei haha
\a \n \t
nnn

lxc@Lxc:~/tt$ cat text1.txt | xargs echo
lalala hahaha heihei haha a n t nnn
lxc@Lxc:~/tt$ vim text1.txt 
lxc@Lxc:~/tt$ cat text1.txt 
lalala
hahaha
heihei haha
'\'a "\"n \\t
nnn

lxc@Lxc:~/tt$ cat text1.txt | xargs echo
lalala hahaha heihei haha \a \n \t nnn
lxc@Lxc:~/tt$ cat text1.txt | xargs -n 2 echo
lalala hahaha
heihei haha
\a \n
\t nnn
lxc@Lxc:~/tt$ cat text1.txt | xargs touch
lxc@Lxc:~/tt$ ls
'\a'   haha   hahaha   heihei   lalala  '\n'   nnn  '\t'   text1.txt   text2.txt   text3.txt
lxc@Lxc:~/tt$ cat text1.txt | xargs rm
lxc@Lxc:~/tt$ ls
text1.txt  text2.txt  text3.txt
```

`xargs` 可以使用从标准输入 *STDIN* 获取的命令行参数并执行指定的命令。它非常适合放在管道的末尾处。

在该脚本中：有下面这一段代码：

```bash
command_1="ps -u $user_account --no-heading"
#
# Create command_3 to kill processes in variable
command_3="xargs -d \\n /usr/bin/sudo /bin/kill -9"
#
# Kill processes via piping commands together
$command_1 | gawk '{print $1}' | $command_3
```

`xargs` 命令被保存在变量 `command_3` 中。选项 `-d` 指定使用什么样的分隔符。也就是说，`xargs` 从 *STDIN* 处接收多个项作为输入，那么各个项之间要怎么区分呢，在这里，`\n`（换行符）被用作各项的分隔符。当 `ps` 命令的输出PID列被传给 `xargs` 时，后者会将每个PID作为单个项来处理。因为 `xargs` 命令被赋给了变量，所以 \n 中的反斜线必须再加上另一个反斜线进行转义。  
注意，在处理PID时，`xargs` 需要使用命令的完整路径名。`xargs` 的现代版本 **不要求** 使用命令的绝对路径。但较旧的Linux发行版可能使用的还是旧版本的 `xargs`，因此我们依然采用了绝对路径写法。 

## 4. 系统监控

[Audit_System.sh](./Audit_System.sh)

系统账户（第7章）用于提供服务或执行特殊任务。一般来说，这类账户需要在 */etc/passwd* 文件中有对应的记录，但禁止登录系统（root账户是一个典型的例外）。  
防止有人使用这些账户登录的方法是，将其默认shell设置为 */bin/false* 、*/usr/sbin/nologin* 或 */sbin/nologin*。当系统账户的默认shell从当前设置更改为 */bin/bash* 时，就会出现问题。虽然 **不良行为者** 在没有设置密码的情况下无法登录到该账户，但这仍会削弱系统的安全性。因此，账户设置需要进行审计，以纠正不正确的默认shell。  
审计这种潜在问题的一种方法是确定有多少账户的默认shell被设置为false或nologin，然后定期检查这一数量。如果发现数量减少，则有必要进一步调查。  

在下面这段代码中，

```bash
cat /etc/passwd | cut -d: -f7 |
grep -E "(nologin|false)" | wc -l |
tee $accountReport
```

`grep` 命令的 `-E` 选线使grep支持ERE（扩展正则表达式），在扩展正则表达式中，选择结构应该放入圆括号并用竖线分隔开。要想让 `grep` 正常工作，还有必不可少的事要做：**shell引用（shell quoting）**。因为圆括号和竖线在bash shell中具有特殊含义，所以必须将其放入引号中，避免shell误解。  
`wc` 命令的 `-l` 选项统计 `grep` 命令生成的结果有多少行。`tee` 命令将结果写入报告文件的同时，还将这一信息显示给脚本用户。

```bash
sudo chattr +i  $accountReport
```

为了保护报告，需要设置 **不可变属性（immutable attribute）**。只要对文件设置了该属性，任何人（包括超级用户）都无法修改或删除此文件（以及一些其它特性）。要设置不可变属性，需要使用 `chattr` 命令，并且具有超级用户权限。  
要想查看属性是否设置成功，可以使用 `lsattr` 命令，并在输出中查找 `i`。要想移除不可变属性，需要再次使用 `chattr` 命令（具有超级用户权限），之后文件就可以被修改或删除了。  
可以查看 `chattr` 命令的手册页，看看还有什么其他的可设置属性。  

```bash
prevReport="$(ls -1t $reportDir/PermissionAudit*.rpt | sed -n '2p')"
```

`ls` 命令 `-t` 选项使输出按照修改时间从新到旧的顺序排序，`-1`（里面是数字1，不是字母l）选项使的输出按照每行一列的格式输出。  

```bash
sudo find / -perm /6000 >$permReport 2>/dev/null 
```

如上，`find` 命令的搜索起点是根目录，`find` 命令的 `-perm` 选项可以使用八进制值指定要查找的具体权限。因为要检查系统中所有的文件和目录，所以需要超级用户权限。注意 `-perm` 的值是 `/6000`.八进制6表示 `find` 要查找的权限是 `SUID` 和 `SGID`。正斜线以及八进制值 `000` 告诉 `find` 命令忽略文件或目录的其余权限。如果没有正斜线，那么 `find` 命令会查找设置了 SUID 权限和 SGID 权限且其他权限均未设置（000）的文件或目录，这当然不是我们想要的。

> 旧版本的 `find` 命令使用加号 `+`  表示忽略某些权限。如果你使用的Linux版本比较旧，则可能需要把正斜线换成加号。

```bash
differences=$(diff $permReport $prevReport)
```

`diff` 命令可以比较文件，并将两者之间的差异输出到 *STDOUT*。`diff` 命令对文件进行逐行比较。因此，`diff` 会比较两分报告中的第一行，然后是第二行、第三行、以此类推。如果由于要安装软件，添加了一个或一批新文件，而这些文件需要SUID或SGID权限，那么在下一次审计时，`diff` 命令就会显示大量的差异。为了解决这个潜在的问题，可以在 `diff` 命令中使用 `-q` 选项或 `--brief` 选项，只显示消息，说明这两份报告存在不同。  