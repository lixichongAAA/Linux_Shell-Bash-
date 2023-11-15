# ch19 初识sed和gawk

传说中的Linux三剑客之二。

## 1. 文本处理

本节将介绍Linux中应用最为广泛的命令行编辑器：sed和gawk

### 1. sed编辑器

sed编辑器被称作 **流编辑器**（stream editor），与普通的交互式文本编辑器（如Vim）截然不同，流编辑器则是根据事先设计好的一组规则编辑数据流。
sed编辑器根据命令来处理数据流中的数据，这些命令要么从命令行输入，要么保存在命令文本文件中。sed编辑器可以执行以下操作。

1. 从输入中读取一行数据。
2. 根据所提供的编辑器命令匹配数据。
3. 按照命令修改数据流中的数据。
4. 将新的数据输出到 *STDOUT*。

在流编辑器匹配并针对一行数据执行所有命令之后，会读取下一行数据并重复这个过程。在流编辑器处理完数据流中的所有行后，就结束运行。
由于命令是按顺序执行的，因此sed编辑器只需对数据流处理一遍(one pass through)即可完成编辑操作。这使得sed编辑器要比交互式编辑器快的多，并且可以快速完成对数据的自动修改。

*sed命令格式如下：*

```bash
sed options script file
```

*options* 参数允许修改sed命令的行为，下表列出了可用的选项。

|选项|描述|
| :------: | :-------------------: |
|-e *commands*|在处理输入时，加入额外的sed命令|
|-f *file*|在处理输入时，将 *file* 中指定的命令添加到已有的命令中|
|-n|不产生命令的输出，使用p(print)命令完成输出|

*script* 参数指定了应用于数据流中的单个命令。如果需要多个命令，则要么使用 `-e` 选项在命令行中指定，要么使用 `-f` 选项在单独的文件中指定。本章将介绍一些sed编辑器的基础命令，然后会在第21章介绍另外一些高级命令。

#### *1. 在命令行中定义编辑器命令*

在默认情况下，sed编辑器会将指定的命令应用于 *STDIN* 输入流中。因此，可以直接将数据通过管道传入sed编辑器进行处理。

*来个例子：*
```bash
lxc@Lxc:~/scripts/ch19$ echo "This is a test" | sed 's/test/big test/'
This is a big test
```

这个例子在sed编辑器中使用了替换(s)命令。替换命令会用斜线间指定的第二个字符串替换第一个字符串。在本例中，*big test* 替换了 *test* 。

```bash
lxc@Lxc:~/scripts/ch19$ cat data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
lxc@Lxc:~/scripts/ch19$ sed 's/dog/cat/' data1.txt 
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
```

> 重要的是，sed编辑器并 **不会** 修改文本文件的数据。它只是将修改后的数据发送到 *STDOUT*。

#### *2. 在命令行中使用多个编辑器命令*

如果要在sed命令行中执行多个命令，可以使用 `-e` 选项。

```bash
lxc@Lxc:~/scripts/ch19$ sed -e 's/brown/red/; s/dog/cat/' data1.txt 
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
```

两个命令都应用于文件的每一行数据。命令之间必须以分号分隔，**并且在命令末尾和分号之间不能有空格**。
如果不想使用分号，那么也可以用bash shell的次提示符来分割命令。只要输入第一个单引号标示出sed程序脚本（也称作sed编辑器命令列表）的起始，bash就会提示继续输入命令，直到输入了标示结束的单引号。

```bash
lxc@Lxc:~/scripts/ch19$ sed -e '
> s/brown/red/
> s/fox/toad/
> s/dof/cat/' data1.txt
The quick red toad jumps over the lazy dog.
The quick red toad jumps over the lazy dog.
The quick red toad jumps over the lazy dog.
The quick red toad jumps over the lazy dog.
```

必须记住，要在闭合单引号所在的行结束命令。bash shell一旦发现了闭合单引号，就会执行命令。sed命令会将你指定的所有命令应用于文本文件的每一行。

#### *3. 从文件中读取编辑器命令*

如果有大量要执行的sed命令，那么将其放进单独的文件通常会更方便一些。可以在sed命令中用 `-f` 选项来指定文件。

```bash
lxc@Lxc:~/scripts/ch19$ cat script1.sed 
s/brown/red/
s/fox/toad/
s/dog/cat/
lxc@Lxc:~/scripts/ch19$ sed -f script1.sed data1.txt 
The quick red toad jumps over the lazy cat.
The quick red toad jumps over the lazy cat.
The quick red toad jumps over the lazy cat.
The quick red toad jumps over the lazy cat.
```

在这种情况下，不用在每条命令后面加分号。sed编辑器知道每一行都是一条单独的命令。和在命令行输入命令一样，sed编辑器会从指定文件中读取命令并应用于文件中的每一行。

> 提示：sed编辑器脚本文件很容易与bash shell脚本文件混淆。为了避免这种情况，可以使用.sed作为sed脚本文件的扩展名。

### 2. gawk编辑器

gawk是Unix中最初的awk的GNU版本。gawk比sed的流编辑器提升了一个段位，它提供了一种编程语言，而不仅仅是编辑器命令。在gawk编程语言中，可以实现以下操作。

- 定义变量来保存数据。
- 使用算术和字符串运算来处理数据。
- 使用结构化编程概念（比如 *if-then* 语句和循环）为数据处理添加处理逻辑。
- 提取文件中的数据并将其重新排列组合，最后生成格式化报告。

gawk的报告生成能力多用于从大文本文件中提取数据并将其格式化为可读性报告。最完美的应用案例是格式化日志文件。

#### *1.gawk的命令格式*

*gawk的基本格式如下：*

```bash
gawk options program file
```

下表列出了gawk的可用选项。

|选项|描述|
| :-------: | :----------------: |
|-F *fs*|指定行中划分数据字段的字段分隔符|
|-f *file*|从指定文件中读取gawk脚本代码|
|-v *var=value*|定义gawk脚本中的变量及其默认值|
|-L *[keyword]*|指定gawk的兼容模式或警告级别|

#### *2. 从命令行读取gawk脚本*

gawk脚本用一对花括号来定义。必须将脚本命令放到一对花括号之间。gawk命令行假定脚本是单个文本字符串，因此还必须将脚本放到单引号中。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch19$ gawk '{print "Hello World"}'
# 这里按下了Enter键
Hello World
# 这里按下了Enter键
Hello World
我输入了一行文本并按下了Enter键
Hello World
```

这个脚本定义了一个命令：`print`。该命令会将文本打印到 *STDOUT*。如果运行这个脚本，什么都不会发生。因为没有在命令行中指定文件名，因此gawk程序会从 *STDIN* 接受数据。在脚本运行时，它会一直等待来自 *STDIN* 的文本，如果你输入一行文本并按下Enter键，则gawk脚本会对这行文本执行一遍脚本。和sed编辑器一样gawk会对数据流中的每一行文本都会执行脚本。所以，你每输入一行文本，都会打印 *Hello World* 的输出。
要终止这个gawk程序，必须表明数据流已经结束了。bash shell提供了Ctrl+D组合键来生成 EOF 字符。使用该组合键可以终止gawk程序并返回到命令行界面。

#### *3. 使用数据字段变量*

gawk的主要特性之一是处理文本文件中的数据。它会自动为每一行的各个数据元素分配一个变量。在默认情况下，gawk会将下列变量分配给文本行中的数据字段。

- `$0` 代表整行文本
- `$1` 代表文本行中的第一个数据字段
- `$2` 代表文本行中的第二个数据字段
- `$n` 代表文本行中的第n个数据字段

文本行中的数据字段是通过 **字段分隔符** 来划分的。在读取一行文本时，gawk会用预先定义好的字段分隔符划分出各个数据字段。在默认情况下，字段分隔符是任意的空白字符(比如空格、制表符等)

*来几个例子：*

```bash
lxc@Lxc:~/scripts/ch19$ cat data2.txt 
One line of the test text.
Two lines of the test text.
Three lines of the test text.
lxc@Lxc:~/scripts/ch19$ gawk '{print $1}' data2.txt 
One
Two
Three
```

这个例子中，gawk脚本会读取文本文件，只显示第一个数据字段的值。该脚本使用 `$1` 字段变量来显示每行文本的第一个数据字段。

如果要读取的文件采用了其他的字段分隔符，可以通过 `-F` 选项指定：

```bash
lxc@Lxc:~/scripts/ch19$ gawk -F: '{print $1}' /etc/passwd
root
daemon
bin
sys
...
```

由于 */etc/passwd* 文件使用冒号来分隔数据字段，因此想要划出数据字段，就必须在gawk选项中将冒号指定为字段分隔符(-F:)。

#### *4. 在脚本中使用多条命令*

gawk编程语言允许将多条命令组合成一个常规脚本。要在命令行指定脚本使用多条命令，只需在命令之间加入分号即可。

```bash
lxc@Lxc:~/scripts/ch19$ echo "My name is lxc" | gawk '{$4="lxcYYDS"; print$0}'
My name is lxcYYDS
```

第一条命令为字段 `$4` 赋值。第二条命令会打印整个文本行。注意，gawk在输出中已经将原文中的第四个数据字段替换成了新值。

当然也可以一次一行地输入脚本命令：

```bash
lxc@Lxc:~/scripts/ch19$ gawk '{
> $4="lxcYYDS"
> print $0
> }'
My name is lxc
My name is lxcYYDS
Your name is son  
Your name is lxcYYDS
```

因为没有在命令行中指定文件名，所以gawk程序会从 *STDIN* 中获取数据。当运行这个脚本时，它会等着读取来自 *STDIN* 的文本。要退出的话，只需按下 Ctrl+D 组合键表明数据结束即可。

#### *5. 从文件中读取脚本*

跟sed编辑器一样，gawk允许将脚本保存在文件中，然后在命令行中引用脚本。

```bash
lxc@Lxc:~/scripts/ch19$ cat script2.gawk 
{print $1 "'s home is " $6}
lxc@Lxc:~/scripts/ch19$ gawk -F: -f script2.gawk /etc/passwd
root's home is /root
daemon's home is /usr/sbin
bin's home is /bin
sys's home is /dev
sync's home is /bin
....
```

当然也可以在脚本文件中指定多条命令。为此，只需一行写一条命令即可，且无须加分号。

```bash
lxc@Lxc:~/scripts/ch19$ cat script3.gawk 
{
text = "'s home is "
print $1 text $6
}
lxc@Lxc:~/scripts/ch19$ gawk -F: -f script3.gawk /etc/passwd
root's home is /root
daemon's home is /usr/sbin
bin's home is /bin
sys's home is /dev
....
```

注意在gawk脚本中，引用变量值时无须像shell脚本那样使用美元符号。

#### *6. 在处理数据前运行脚本*

gawk还允许指定脚本何时运行。在默认情况，gawk会从输入读取一行文本，然后对这一行数据执行脚本。但在有些时候，可能需要在处理数据前先运行脚本，比如要为报告创建一个标题。`BEGIN` 关键字就是用来做这个的。它会强制gawk在读取数据前执行 `BEGIN` 关键字之后指定的脚本：

```bash
$ gawk 'BEGIN {print "Hello World"}'
Hello World
```

这次 `print` 命令会在读取数据前显示文本。但在显示过文本之后，脚本就直接结束了，不等待任何数据。
原因在于 `BEGIN` 关键字在处理任何数据之前仅应用指定的脚本。如果想使用正常的脚本来处理数据，则必须用另一个区域来定义脚本：

```bash
lxc@Lxc:~/scripts/ch19$ cat data3.txt 
Line 1
Line 2
Line 3
lxc@Lxc:~/scripts/ch19$ gawk 'BEGIN {print "The date3 file Contents: "}
> {print $0}' data3.txt
The date3 file Contents: 
Line 1
Line 2
Line 3
```

#### *7. 在处理数据后运行脚本*

和 `BEGIN` 关键字类似，`END` 关键字允许指定一段脚本，gawk会在处理完数据后执行这段脚本。

```bash
lxc@Lxc:~/scripts/ch19$ gawk 'BEGIN {print "The data3 Dile Contents:"}
> {print $0}
> END {print "End of File"}' data3.txt
The data3 Dile Contents:
Line 1
Line 2
Line 3
End of File
```

gawk在打印完文件内容后，会执行 `END` 脚本中的命令。这是在处理完所有正常数据后给报告添加页脚的最佳方法。

*来个例子：*

[script4.gawk](./script4.gawk)

```bash
BEGIN {
print "The latest list of users and shells"
print "UerID   \t Shell"
print "-----   \t -----"
FS=":"
}

{
print $1 "       \t " $7
}

END {
print "The concludes the listing"
}
# output:
lxc@Lxc:~/scripts/ch19$ gawk -f script4.gawk /etc/passwd
The latest list of users and shells
UerID            Shell
-----            -----
root             /bin/bash
daemon           /usr/sbin/nologin
bin              /usr/sbin/nologin
....
nobody           /usr/sbin/nologin
The concludes the listing
```

`print` 命令中的 `-t` 负责生成美观的 **选项卡式输出（tabbed output）**。

## 2. sed编辑器基础命令

### 1. 更多的替换选项

前面已经讲过如何用替换命令在文本行替换文本。这个命令还有另外一些能简化操作的选项。

#### *1. 替换标志*

替换命令在替换多行中的文本时也能正常工作，但在默认情况下它只替换每行中出现的第一处匹配文本。要想替换每行中所有的匹配文本，必须使用 **替换标志(substitution flag)** 。替换标志在替换命令字符串之后设置。

```bash
s/pattern/replacement/flags
```

有4种可用的替换标志。

- 数字，指明新文本将替换行中的第几处匹配。
- g，指明新文本将替换行中所有的匹配。
- p，指明打印出替换后的行。
- w *file* ，将替换的结果写入文件。

第一种替换表示，你可以告诉sed编辑器用新文本替换第几处匹配文本：

```bash
lxc@Lxc:~/scripts/ch19$ cat data4.txt 
This is a test of the test script.
This is the second test of the test script.

lxc@Lxc:~/scripts/ch19$ sed 's/test/trial/2' data4.txt 
This is a test of the trial script.
This is the second test of the trial script.
# 如你所见，替换了每行中第二处匹配文本。
```

替换标志 `g` 可以替换文本行中所有的匹配文本。

```bash
lxc@Lxc:~/scripts/ch19$ cat data4.txt 
This is a test of the test script.
This is the second test of the test script.

lxc@Lxc:~/scripts/ch19$ sed 's/test/trial/g' data4.txt 
This is a trial of the trial script.
This is the second trial of the trial script.
```

替换标志 `p` 会打印出包含替换命令中指定匹配模式的文本行。该标志通常和sed的 `-n` 选项配合使用。

```bash
lxc@Lxc:~/scripts/ch19$ cat data5.txt 
This is a test line.
This is a different line.

lxc@Lxc:~/scripts/ch19$ sed -n 's/test/trial/p' data5.txt 
This is a trial line.
```

`-n` 选项会抑制sed编辑器的输出，而替换标志 `p` 会输出替换后的行。将二者配合使用的结果就是只输出被替换命令修改过的行。

替换标志 `-w` 会产生同样的输出，不过会将输出保存到指定文件中。

```bash
lxc@Lxc:~/scripts/ch19$ sed  's/test/trial/w test.txt' data5.txt 
This is a trial line.
This is a different line.

lxc@Lxc:~/scripts/ch19$ cat test.txt 
This is a trial line.
```

sed编辑器的正常输出会被保存在 *STDOUT* 中，只有那些包含匹配模式的行才会被保存在指定的输出文件中。

### 2. 使用地址

在默认情况下，在sed编辑器中使用的命令会应用于所有的文本行。如果只想将命令应用于特定的某一行或某些行，则必须使用 **行寻址**。
在sed编辑器中有两种形式的行寻址。

- 以数字形式表示的行区间。
- 匹配行内文本的模式。

以上两种形式使用相同的格式来指定地址。

```bash
[address]command
```

也可以将针对特定地址的多个命令分组：

```bash
address {
    command1
    command2
    command3
}
```

sed编辑器会将指定的各个命令应用于匹配指定地址的文本行。

#### *1. 数字形式的行寻址*

在使用数字形式的行寻址时，可以用行号来引用文本流中的特定行。sed编辑器会将文本流中的第一行编号为1，第二行编号为2，以此类推。
在命令行中指定的行地址可以是单个行号，也可以是用起始行号、逗号以及结尾行号指定的行区间。

*来几个例子：*

```bash
lxc@Lxc:~/scripts/ch19$ cat data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

lxc@Lxc:~/scripts/ch19$ sed '2s/dog/cat/' data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
```

sed编辑器只修改了地址所指定的第二行文本。

```bash
lxc@Lxc:~/scripts/ch19$ sed '2,3s/dog/cat/' data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
```

这次使用了行区间，替换了第2、3行。

如果想将命令应用于从某行开始到结尾的所有行，可以使用美元符号作为结尾行号。

```bash
lxc@Lxc:~/scripts/ch19$ sed '2,$s/dog/cat/' data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
```

如你所见，替换了从第2行开始到最后一行。因为往往不知道文本中有多少行，所以美元符号用起来很方便。

#### *2. 使用文本模式过滤*

另一种限制命令应用于哪些行的方法略显复杂。sed编辑器允许指定文本模式来过滤出命令所应用的行，其格式如下：

```bash
/pattern/command
```

必须将指定的模式放入正斜线内。sed编辑器会将该命令应用于包含匹配模式的行。

*来个例子：*

```bash
$ grep /bin/bash /etc/passwd
lxc:x:1000:1000:Lxc,,,:/home/lxc:/bin/bash

lxc@Lxc:~/scripts/ch19$ sed '/lxc/s/bash/csh/' /etc/passwd
lxc:x:1000:1000:Lxc,,,:/home/lxc:/bin/csh
....
```

如你所见，该命令只应用于包含匹配模式的行。虽然使用固定的文本模式有助于过滤出特定的值，就跟上面的例子一样，但难免有所局限。sed编辑器在文本模式中引入了正则表达式（见第20章）来创建匹配效果更好的模式。

#### *3. 命令组*

如果需要在单行中执行多条命令，可以用花括号将其组合在一起，sed编辑器会执行匹配地址中列出的所有命令。

```bash
lxc@Lxc:~/scripts/ch19$ sed '2{
> s/fox/toad/
> s/dog/cat/
> }' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown toad jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
```

这两条命令都会应用于该地址。当然，也可以在一组命令前指定区间。

```bash
lxc@Lxc:~/scripts/ch19$ sed '2,${
> s/brown/red/
> s/fox/toad/
> s/lazy/sleeping/
> }' data1.txt
The quick brown fox jumps over the lazy dog.
The quick red toad jumps over the sleeping dog.
The quick red toad jumps over the sleeping dog.
The quick red toad jumps over the sleeping dog.
# 如你所见，我就不用解释了吧。
```

### *3. 删除行*

如果需要删除文本流中的特定行，可以使用删除命令(d)。
删除命令很简单，它会删除匹配指定模式的所有行。使用该命令时要小心，如果忘记加入寻址模式，则流中的所有文本行都会被删除：

```bash
lxc@Lxc:~/scripts/ch19$ cat data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

lxc@Lxc:~/scripts/ch19$ sed 'd' data1.txt 
# 都删除，当然没输出啦。
```

当和指定地址一起使用时，删除命令显然能发挥出最大的功用。可以从数据流中删除特定的文本行，这些文本行要么通过行号指定：

```bash
lxc@Lxc:~/scripts/ch19$ cat data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.

lxc@Lxc:~/scripts/ch19$ sed '3d' data6.txt 
This is line number 1.
This is line number 2.
This is the 4th line.
```

要么通过特定行区间指定：

```bash
lxc@Lxc:~/scripts/ch19$ sed '2,3d' data6.txt 
This is line number 1.
This is the 4th line.
```

要么通过特殊的末行字符指定：

```bash
lxc@Lxc:~/scripts/ch19$ sed '3,$d' data6.txt 
This is line number 1.
This is line number 2.
```

当然模式匹配特性也适用于删除命令：

```bash
lxc@Lxc:~/scripts/ch19$ sed '/number 1/d' data6.txt 
This is line number 2.
This is the 3rd line.
This is the 4th line.
```

sed编辑器会删除掉与指定模式相匹配的文本行。

> **注意：** sed编辑器 **不会修改原始文件**。你删除的行只是从sed编辑器的输出中消失了。

也可以使用两个文本模式来删除某个区间内的行。但这么做时要小心，你指定的第一个模式会启用行删除功能，第二个模式会关闭行删除功能，而sed编辑器会删除两个指定行之间的所有行（当然包括指定的行）：

```bash
lxc@Lxc:~/scripts/ch19$ sed '/1/,/3/d' data6.txt 
This is the 4th line.
```

除此之外，要特别小心，因为只要sed编辑器在数据流中匹配到了开始模式，就会启用删除功能，如果没有找到停止模式，就会一直执行删除，直到尾行。

```bash
lxc@Lxc:~/scripts/ch19$ cat data7.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
This is line number 1 again; we want to keep it.
This is more text we want to keep.
Last line in the file; we want to keep it.

lxc@Lxc:~/scripts/ch19$ sed '/1/,/3/d' data7.txt 
This is the 4th line.
```

第二个包含数字 "1" 的行再次触发了删除指令，因为没有找到停止模式，所以数据流中的剩余文本行全部被删除了。当然，如果指定的停止模式始终未在文本中出现，就会出现删除到尾行的情况。

```bash
lxc@Lxc:~/scripts/ch19$ sed '/3/,/5/d' data7.txt 
This is line number 1.
This is line number 2.
```

删除功能在匹配到开始模式的时候就启用了，但由于一直未能匹配到结束模式，因此没有关闭，最终整个数据流都被删除了。

### *4. 插入和附加文本*

sed编辑器也可以向数据流中插入和附加文本行。

- 插入(insert)(i)命令会在指定行 **前** 增加一行。
- 附加(append)(a)命令会在指定行 **后** 增加一行。

这两条命令不能在单个命令行中使用。必须指定是将行插入还是附加到另一行，其格式如下：

```bash
sed '[address]command\
new line'
```

*new line* 中的文本会出现在你所指定的sed编辑器的输出位置。当使用插入命令时，文本会出现在数据流文本之前：

```bash
lxc@Lxc:~/scripts/ch19$ echo "Test Line 2" | sed 'i\Test Line 1'
Test Line 1
Test Line 2
```

当使用附加命令时，文本会出现在数据流文本之后：

```bash
lxc@Lxc:~/scripts/ch19$ echo "Test Line 2" | sed 'a\Test Line 1'
Test Line 2
Test Line 1
```

在命令行界面使用sed编辑器时，你会看到次提示符，它会提醒输入新一行的数据。必须在此行完成sed编辑器命令。一旦输入表示结尾的后单引号，bash shell就会执行该命令：

```bash
lxc@Lxc:~/scripts/ch19$ echo "Test Line 2" | sed 'i\
> Test Line 1'
Test Line 1
Test Line 2
```

要向数据流内部插入或附加数据，必须用地址告诉sed编辑器希望数据出现在什么位置。用这些命令时只能指定一个行地址。使用行号或文本模式都行，但不能用行区间。这也说的通，因为只能将文本插入或附加到某一行而不是行区间的前面或后面。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch19$ cat data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.

lxc@Lxc:~/scripts/ch19$ sed '3i\
> This is an inserted line.
> ' data6.txt
This is line number 1.
This is line number 2.
This is an inserted line.
This is the 3rd line.
This is the 4th line.
# 如你所见，这个例子将新文本行插入到第3行之前。
```

下面这个例子将新行附加到数据流中的第三行之后：

```bash
lxc@Lxc:~/scripts/ch19$ sed '3a\
> This is an insertetd line.
> ' data6.txt
This is line number 1.
This is line number 2.
This is the 3rd line.
This is an insertetd line.
This is the 4th line.
```

同样，如果你想将新行附加到数据流的末尾，那么只需用代表数据流最后一行的美元符号即可：

```bash
lxc@Lxc:~/scripts/ch19$ sed '$a\
> This line was added to the end of the file.
> ' data6.txt
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
This line was added to the end of the file.
```

当然，如果你想在第一行之前增加一个新行。这只要在第一行之前插入新行就可以。

要插入或附加多行文本，必须在要插入或附加的每行新文本末尾使用反斜线：

```bash
lxc@Lxc:~/scripts/ch19$ sed '1i\
> This is an inserted line.\
> This is another inserted line.
> ' data6.txt
This is an inserted line.
This is another inserted line.
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
```

### *5. 修改行*

修改(c)命令允许修改数据流中整行文本的内容。它跟插入和附加命令的工作机制一样，必须在sed命令中单独指定一行：

```bash
$ sed '2c\
> This is a changed line of text.
> ' data6.txt
This is line number 1.
This is a changed line of text.
This is the 3rd line.
This is the 4th line.
```

也可以用文本模式来寻址，这个例子中，sed编辑器会修改第3行文本：

```bash
$ sed '/3rd line/c\
> This is a changed line of text.
> ' data6.txt
This is line number 1.
This is line number 2.
This is a changed line of text.
This is the 4th line.
```

文本模式会修改所匹配到的任意文本行：

```bash
$ cat data8.txt 
I have 2 Infinity Stones 
I need 4 more Infinity Stones
I have 6 Infinity Stones!
I need 4 Infinity Stones
I have 6 Infinity Stones...
I want 1 more Infinity Stone 

$ sed '/have 6 Infinity Stones/c\
> Snap! This is changed line of text.
> ' data8.txt
I have 2 Infinity Stones 
I need 4 more Infinity Stones
Snap! This is changed line of text.
I need 4 Infinity Stones
Snap! This is changed line of text.
I want 1 more Infinity Stone 
```

可以在修改命令中使用地址区间，但sed编辑器会用指定的文本替换指定地址区间的文本，而不是逐一修改：

```bash
$ cat data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.

lxc@Lxc:~/scripts/ch19$ sed '2,3c\
> This is a changed line of text.
> ' data6.txt
This is line number 1.
This is a changed line of text.
This is the 4th line.
```

### *6. 转换命令*

转换（y）命令是唯一一个可以处理单个字符的sed编辑器命令。

*命令格式：*

```bash
[address]y/inchars/outchars/
```

转换命令会对 *inchars* 和 *outchars* 进行一对一的映射。 *inchars* 中的第一个字符会被转换成为 *outchars* 中的第一个字符， *inchars* 中的第二个字符会被转换成为 *outchars* 的第二个字符。这个映射过程会一直持续到处理完指定字符。如果 *inchars* 和 *outchars* 的长度不同，则sed编辑器会产生一条错误消息。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch19$ cat data9.txt 
This is line 1.
This is line 2.
This is line 3.
This is line 4.
This is line 5.
This is line 1 again.
This is line 3 again.
This is the last file line.

lxc@Lxc:~/scripts/ch19$ sed 'y/123/789/' data9.txt 
This is line 7.
This is line 8.
This is line 9.
This is line 4.
This is line 5.
This is line 7 again.
This is line 9 again.
This is the last file line.
# 如你所见，inchars中的各个字符都会被替换成outchars中相同位置的字符。
```

转换命令是一个全局命令，也就是说，它会对文本行中匹配到的所有指定字符进行转换，不考虑字符出现的位置：

```bash
lxc@Lxc:~/scripts/ch19$ echo "Test #1 of try #1." | sed 'y/123/678/'
Test #6 of try #6.
```

### 7. 再探打印

之前介绍过如何使用p标志和替换命令显示sed编辑器修改过的行。另外，还有3个命令也能打印数据流中的信息。

- 打印（p）命令用于打印文本行。
- 等号（=）命令用于打印行号。
- 列出（l）命令用于列出行。

接下来介绍这三个sed编辑器的打印命令。

#### *1. 打印行*

和替换命令中的 `p` 标志类似，打印命令用于打印sed编辑器输出中的一行。如果只用这个命令，倒也没什么特别的：

```bash
lxc@Lxc:~/scripts/ch19$ echo "This is a test" | sed 'p'
This is a test
This is a test
```

它所做的就是打印已有的数据文本。打印命令最常见的用法是打印包含匹配文本模式的行：

```bash
lxc@Lxc:~/scripts/ch19$ cat data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.

lxc@Lxc:~/scripts/ch19$ sed -n '/3rd line/p' data6.txt 
This is the 3rd line.
# 在命令行中使用-n选项可以抑制其他行的输出，只打印包含匹配文本模式的行。
```

也可以用它来快速打印数据流中的部分行：

```bash
lxc@Lxc:~/scripts/ch19$ sed -n '2,3p' data6.txt 
This is line number 2.
This is the 3rd line.
```

如果需要在使用替换或修改命令做出改动之前查看相应的行，可以使用打印命令。

```bash
lxc@Lxc:~/scripts/ch19$ sed -n '/3/{
> p
> s/line/test/p
> }' data6.txt
This is the 3rd line.
This is the 3rd test.
```

这个例子中，sed编辑器会首先查找包含数字3的行，然后执行两条命令。第一条命令打印出原始的匹配行。第二条命令用替换命令替换文本并通过p标志打印出替换结果。输出同时显示了原始的文本行和新的文本行。

#### *2. 打印行号*

等号命令会打印文本行在数据流中的行号。行号由数据流中的换行符决定。数据流中每出现一个换行符，sed编辑器就会认为有一行文本结束了。

```bash
lxc@Lxc:~/scripts/ch19$ cat data1.txt 
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
  
lxc@Lxc:~/scripts/ch19$ sed '=' data1.txt 
1
The quick brown fox jumps over the lazy dog.
2
The quick brown fox jumps over the lazy dog.
3
The quick brown fox jumps over the lazy dog.
4
The quick brown fox jumps over the lazy dog.
```

sed编辑器在实际文本行之前会先打印行号。如果要在数据流中查找特定文本，那么等号命令用起来特别方便：

```bash
lxc@Lxc:~/scripts/ch19$ cat data7.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
This is line number 1 again; we want to keep it.
This is more text we want to keep.
Last line in the file; we want to keep it.

lxc@Lxc:~/scripts/ch19$ sed -n '/text/{
> =
> p
> }' data7.txt
6
This is more text we want to keep.
```

利用 `-n` 选项，就能让sed编辑器只显示包含匹配文本模式的文本行的行号和内容。

#### *3. 列出行*

列出命令可以打印数据流中的文本和不可打印字符。在显示不可打印字符的时候，要么在其八进制前加一个反斜线，要么使用标准的C语言命名规范（用于常见的不可打印字符），比如\t用于代表制表符：

```bash
lxc@Lxc:~/scripts/ch19$ cat data10.txt 
This    line    contains        tabs.
This line does contain tabs.

lxc@Lxc:~/scripts/ch19$ sed -n 'l' data10.txt 
This\tline\tcontains\ttabs.$
This line does contain tabs.$
```

制表符所在的位置显示为\t。行尾的美元符号表示换行符。如果数据流包含转义字符，则列出命令会在必要时用八进制值显示：

```bash
lxc@Lxc:~/scripts/ch19$ cat data11.txt 
This line contains an escape character. 

lxc@Lxc:~/scripts/ch19$ sed -n 'l' data11.txt 
This line contains an escape character. \a$
```

data11.txt文本文件含有一个用于产生铃声的转移控制码。当用 `cat` 命令显示文本文件时，转义控制码不会显示出来，你只能听到声音（如果打开了音箱的话）。但利用列出命令，就能显示出所使用的转义控制码。

### 8. 使用sed处理文件

替换命令包含一些文件处理标志。一些常规的sed编辑器命令也可以让你无须替换文本即可完成此操作。

#### *1. 写入文件*

写入（w）命令用向文件写入行。

*命令格式：*

```bash
[address]w filename
```

*filename* 可以使用相对路径或者绝对路径，但不管使用哪种，运行sed编辑器的用户都必须有文件的写入权限。*address* 可以是sed支持的任意类型的寻址方式，比如单个行号、文本模式、行区间或文本模式区间。

下面的例子会将数据流中的前两行写入文本文件：

```bash
lxc@Lxc:~/scripts/ch19$ sed -n '1,2w test.txt' data6.txt 
lxc@Lxc:~/scripts/ch19$ cat test.txt 
This is line number 1.
This is line number 2.
```

如果要根据一些共用的文本值，从主文件中创建一份数据文件，则使用写入命令会非常方便：

```bash
lxc@Lxc:~/scripts/ch19$ cat data12.txt 
Blum, R       Browncoat
McGuiness, A  Alliance
Bresnahan, C  Browncoat
Harken, C     Alliance

lxc@Lxc:~/scripts/ch19$ sed -n '/Browncoat/w Browncoat.txt' data12.txt 
lxc@Lxc:~/scripts/ch19$ cat Browncoat.txt 
Blum, R       Browncoat
Bresnahan, C  Browncoat
```

如你所见，sed编辑器会将匹配文本模式的数据行写入文件。

#### *2. 从文件读取数据*

你已经知道如何通过sed命令行向数据流插入文本或附件文本。读取（r）命令允许将一条独立文件中的数据插入数据流。

*命令格式如下：*

```bash
[address]r filename
```

*filename* 参数指定了数据文件的绝对路径或相对路径。读取命令无法使用地址区间，只能指定单个文本号或文本模式地址。sed编辑器会将文件内容插入到指定地址之后：

```bash
lxc@Lxc:~/scripts/ch19$ cat data13.txt 
This is an added line.
This is a second added line.

lxc@Lxc:~/scripts/ch19$ sed '3r data13.txt' data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is an added line.
This is a second added line.
This is the 4th line.
# 该命令是读取 data13.txt 的数据插入到 data6.txt 第3行之后。
```

sed编辑器会将数据文件中的所有文本行都插入数据流。在使用文本模式地址时，同样的方法也适用：

```bash
lxc@Lxc:~/scripts/ch19$ sed '/number 2/r data13.txt' data6.txt 
This is line number 1.
This is line number 2.
This is an added line.
This is a second added line.
This is the 3rd line.
This is the 4th line.
# 该命令是在 data6.txt 文件中查找匹配 number 2 模式的文本行，并在该行之后插入 data13.txt 文件的全部数据。

lxc@Lxc:~/scripts/ch19$ cat data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is line number 2.
This is the 4th line.

lxc@Lxc:~/scripts/ch19$ sed '/number 2/r data13.txt' data6.txt 
This is line number 1.
This is line number 2.
This is an added line.
This is a second added line.
This is the 3rd line.
This is line number 2.
This is an added line.
This is a second added line.
This is the 4th line.
```

要在数据流末尾添加文本，只需使用美元符号地址即可：

```bash
lxc@Lxc:~/scripts/ch19$ sed '$r data13.txt' data6.txt 
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
This is an added line.
This is a second added line.
```

该命令还有一种很酷的用法是和删除命令配合使用，利用另一个文件中的数据来替换文件中的占位文本。
假如你保存在文本文件中的套用信件如下所示：

```bash
lxc@Lxc:~/scripts/ch19$ cat notice.std 
Would the following people:
LIST
please report to the ship's captain.
```

套用信件将通用占位文本 *LIST* 放在了人物名单的位置。要在占位文本后插入名单，只需使用读取命令即可。但这样的话，占位文本仍然会留在输出中。为此，可以用删除命令删除占位文本，其结果如下：

```bash
lxc@Lxc:~/scripts/ch19$ sed '/LIST/{
> r data12.txt
> d
> }' notice.std
Would the following people:
Blum, R       Browncoat
McGuiness, A  Alliance
Bresnahan, C  Browncoat
Harken, C     Alliance
please report to the ship's captain.
```

如你所见，现在占位文本已经被替换成了数据文件中的名单。

## 3. 实战演练

在第11章，我们讲过shell脚本文件的第一行：

```bash
#!/bin/bash
```

第一行有时被称为 `shebang`（`shebang` 这个词其实是两个字符名称(sharp-bang)的简写。在Unix专业术语中，用 sharp 或 hash（有时候是mesh）来称呼字符 "#"，用 bang 来称呼惊叹号 "!"，因而shebang 合起来就代表了这两个字符 #!），在传统的Unix shell脚本中其形式如下：

```bash
#!/bin/sh
```

这种传统通常也延续到了Linux的bash shell脚本，这在过去不是问题，大多数发行版将 */bin/sh* 链接到了 bash shell(/bin/bash)，因此，如果在脚本中使用 */bin/sh* 就相当于写的是 */bin/bash* ：

```bash
lxc@Lxc:~/scripts/ch19$ ls -l /bin/sh
lrwxrwxrwx 1 root root 13 11月  9 21:35 /bin/sh -> /usr/bin/bash
# 我使用的是Ubuntu，但如你所见，我在11月13号的晚上21:35分修改了该软连接，使其指向了bash
```

在某些Linux发行版(比如Ubuntu)中，*/bin/sh* 文件并没有链接到bash shell。

```bash
lxc@Lxc:~/scripts/ch19$ ls -l /bin/sh
lrwxrwxrwx 1 root root 13 11月  9 21:35 /bin/sh -> dash
```

在这类系统中运行的shell脚本，如果使用 */bin/sh* 作为 shebang，则脚本会运行在 dash shell 而非 bash shell 中。这可能会造成很多shell脚本命令执行失败。

现在我们搞一个脚本，使以dash shell运行的脚本文件运行在bash shell上。

[ChangeScriptShell.sh](./ChangeScriptShell.sh)

```bash
#!/bin/bash
# Change the shebang used for a directory of scripts
#
################## Function Declarations ##########################
#
function errorOrExit {
	echo
	echo $message1
	echo $message2
	echo "Exiting script..."
	exit
}
#
function modifyScripts {
	echo
	read -p "Directory name in which to store new scripts? " newScriptDir
	#
	echo "Modifying the scripts started at $(date +%N) nanoseconds"
	#
	count=0
	for filename in $(grep -l "/bin/sh" $scriptDir/*.sh)
	do
		newFilename=$(basename $filename)
		cat $filename | 
		sed '1c\#!/bin/bash' > $newScriptDir/$newFilename
		count=$[$count + 1] 
	done
	echo "$count modifications completed at $(date +%N) nanoseconds"
}
#
################# Check for Script Directory ######################
if [ -z $1 ]
then 
	message1="The name of the directory containing scripts to check"
	message2="is missing. Please provide the name as a parameter."
        errorOrExit
else
	scriptDir=$1
fi 
#
################ Create Shebang Report ############################
#
sed -sn '1F; 
1s!/bin/sh!/bin/bash!' $scriptDir/*.sh | 
gawk 'BEGIN {print ""
print "The following scripts have /bin/sh as their shebang:"
print "==================================================="}
{print $0}
END {print ""
print "End of Report"}'
#
################## Change Scripts? #################################
#
#
echo
read -p "Do you wish to modify these scripts' shebang? (Y/n)? " answer
#
case $answer in
Y | y)
	modifyScripts
	;;
N | n)
	message1="No scripts will be modified."
	message2="Run this script later to modify, if desired."
	errorOrExit
	;;
*)
	message1="Did not answer Y or n."
	message2="No scripts will be modified."
	errorOrExit
	;;
esac
```

sed命令行中的 `-s` 选项可以告知sed将目录内的各个文件作为单独的流，这样可以检查目录下每个文件的第一行。`-n` 选项则会抑制输出，这样就不会看到脚本的内容了：

```bash
sed -sn '1s!/bin/sh!/bin/bash!' OldScripts.*.sh
```

sed命令行中用到的另一个命令是 `F`。该命令会告知sed打印出当前正在处理的文件名，且不受 `-n` 选项的影响。因为脚本文件名只需显示一次即可，所以要在 `F` 命令之前加上数字1（否则的话，所处理的每个文件的每一行都会显示文件名）。现在，我们可以知道哪些脚本使用的是旧式的shebang：

```bash
sed -sn '1F;
> 1s!/bin/sh!/bin/bash!' OldScripts/*.sh
```