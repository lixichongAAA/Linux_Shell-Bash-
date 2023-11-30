# ch21 sed进阶

第19章展示了如何用sed编辑器的基本功能来处理数据流中的文本。sed编辑器的基础命令能满足大多数日常文本编辑的需要。本章将介绍sed编辑器所提供的更多高级特性。

## 1. 多行命令

在之前使用sed编辑器的基础命令时，你可能注意到了一个局限：所有的命令都是针对单行数据执行操作。在sed编辑器读取数据流时，它会根据换行符的位置将数据分成行。sed编辑器会根据定义好的脚本命令，一次一行处理数据，然后移到下一行重复这个过程。  
但有时候，你需要对跨多行的数据执行特定的操作。幸运的是，sed编辑器有对应的解决方案。sed编辑器提供了3个可用于处理多行文本的特殊命令。

- N：加入数据流中的下一行，创建一个多行组进行处理。
- D：删除多行组中的一行。
- P：打印多行组中的一行。

### 1. `next` 命令

在讲解多行 `next(N)` 命令之前，首先需要知道单行版本的 `next` 命令是如何工作的，这样一来，理解多行版本的 `next` 命令的用法就容易多了。

#### *1. 单行 `next` 命令*

单行 `next(n)` 命令会告诉sed编辑器移动到数据流中的下一行，不用再返回到命令列表的最开始位置。记住，通常sed编辑器在移动到数据流中的下一行之前，会在当前行执行完所有定义好的命令，而单行的 `next` 命令改变了这个流程。

*来个例子：*

比如我们想删除 *data1.txt* 文件首行之后的空行，其他空行保留。

```bash
lxc@Lxc:~/scripts/ch21$ cat data1.txt 
Header Line

Data Line #1

End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed '/^$/d' data1.txt 
Header Line
Data Line #1
End of Data Lines
# 执行普通的空行匹配会删除所有空行。
lxc@Lxc:~/scripts/ch21$ sed '/Header/{n; d}' data1.txt
Header Line
Data Line #1

End of Data Lines
```

在这个例子中，先用脚本查找到含有单词 *Header* 的那一行，找到之后，单行 `next` 命令会让sed编辑器移动到文本的下一行，也就是我们想要删除的行，然后继续执行命令列表，使用删除命令删除空行。sed编辑器在执行完命令之后会读取数据流中的下一行文本，从头开始执行脚本。

#### *2. 合并文本行*

现在来看看多行版的 `next` 命令。 单行的 `next` 命令会将数据流中的下一行移入sed编辑器的工作空间（称为 **模式空间**）。多行版本的 `next` 命令则是将下一行添加到模式空间已有文本之后。这样的结果就是将数据流中的两行文本合并到同一个模式空间中。在文本行之间仍然用换行符分隔，但sed编辑器现在会将两行文本**当成一行**来处理。

```bash
lxc@Lxc:~/scripts/ch21$ cat data2.txt 
Header Line
First Data Line
Second Data Line
End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed '/First/{N;s/\n/ /}' data2.txt 
Header Line
First Data Line Second Data Line
End of Data Lines
```

sed编辑器首先查找到含有单词 *First* 的那行文本，找到该行后，使用 `N` 命令将下一行与该行合并，然后用替换命令将换行符替换成了空格。这样，两行文本在sed编辑器的输出中就成了一行。

如果要在数据文件中查找一个可能会分散在两行中的文本短语，那么这会是一个很管用的方法：

```bash
lxc@Lxc:~/scripts/ch21$ cat data3.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All System Admins should attend.
Thank you for your cooperation. 
lxc@Lxc:~/scripts/ch21$ sed 's/System.Admin/Devops Engineer/' data3.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All Devops Engineers should attend.
Thank you for your cooperation. 
lxc@Lxc:~/scripts/ch21$ sed 'N;s/System.Admin/Devops Engineer/' data3.txt 
On Tuesday, the Linux Devops Engineer group meeting will be held.
All Devops Engineers should attend.
Thank you for your cooperation. 
```

注意，替换命令在 *System* 和 *Admin* 之间用点号模式(.)来匹配空格和换行符这两种符号(前文有讲，说点号模式不匹配换行符，这里又说点号模式匹配了换行符，呃，这是sed编辑器将两行合并为一行的缘故吧应该是)。这导致了两行被合并为一行。

要解决这个问题，可以在sed编辑器使用两个替换命令，一个用来处理短语出现在多行的情况，一个用来处理短语出现在单行的情况。

```bash
lxc@Lxc:~/scripts/ch21$ sed 'N;
> s/System\nAdmin/DevOps\nEngineer/
> s/System Admin/DevOps Engineer/
> ' data3.txt
On Tuesday, the Linux DevOps
Engineer group meeting will be held.
All DevOps Engineers should attend.
Thank you for your cooperation. 
```

但这里还有一个不易察觉的问题，该脚本总是在执行sed编辑器命令前将下一行文本读入模式空间，当抵达最后一行文本时，就没有下一行可读了，这时 `N` 命令会叫停sed编辑器。如果恰好要匹配的文本在最后一行，那么命令就无法找到要匹配的数据：

```bash
lxc@Lxc:~/scripts/ch21$ cat data4.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All System Admins should attend.
lxc@Lxc:~/scripts/ch21$ sed 'N
> s/System\nAdmin/DevOps\nEngineer/
> s/System Admin/DevOps Engineer/
> ' data4.txt
On Tuesday, the Linux DevOps
Engineer group meeting will be held.
All System Admins should attend.
```

*Sytem Admin* 文本出现在了数据流中的最后一行，但 `N` 命令会错过它，因为没有其他行可以读入模式空间跟这行合并。这个问题不难解决，将单行编辑器命令放到 `N` 命令前面，将多行编辑器命令放到 `N` 命令后面就可以了。

```bash
lxc@Lxc:~/scripts/ch21$ sed ' 
s/System Admin/DevOps Engineer/
N
s/System\nAdmin/DevOps\nEngineer/
' data4.txt
On Tuesday, the Linux DevOps
Engineer group meeting will be held.
All DevOps Engineers should attend.
```

### *2. 多行删除命令*

第19行介绍过单行删除(d)命令。sed编辑器用该命令来删除模式空间中的当前行。然而，如果和 `N` 命令一起使用，则必须小心单行删除命令：

```bash
lxc@Lxc:~/scripts/ch21$ cat data4.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All System Admins should attend.
lxc@Lxc:~/scripts/ch21$ sed 'N; /System\nAdmin/d' data4.txt 
All System Admins should attend.
```

单行删除命令会在不同行中查找单词 *System* 和 *Admin*，然后在模式空间中将两行都删除，这未必是你想要的结果。

sed编辑器提供了多行删除（D）命令，该命令只会删除模式空间中的第一行，即删除该行中的换行符及其之前的内容。

```bash
lxc@Lxc:~/scripts/ch21$ sed 'N; /System\nAdmin/D' data4.txt 
Admin group meeting will be held.
All System Admins should attend.
```

这里有个例子，删除数据流中出现在第一行之前的空行：

```bash
lxc@Lxc:~/scripts/ch21$ cat data5.txt 

Header Line
First Data Line

End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed '/^$/{N; /Header/D}' data5.txt 
Header Line
First Data Line

End of Data Lines
```

sed编辑器脚本会查找空行，然后用 `N` 命令将下一行加入模式空间。如果模式空间中含有单词 *Header*，则 `D` 命令会删除模式空间中的第一行。如果不综合使用 `D` 命令和 `N` 命令，无法做到在不删除其他行的情况下只删除第一个空行。

### *3. 多行打印命令*

多行打印命令(P)，它只打印模式空间中的第一行，即打印模式空间中换行符及其之前的所有字符。当用 `-n` 选项抑制脚本输出时，它和显示文本的单行 `p` 命令的用法大同小异:

```bash
lxc@Lxc:~/scripts/ch21$ cat data3.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All System Admins should attend.
Thank you for your cooperation. 
lxc@Lxc:~/scripts/ch21$ sed -n 'N; /System\nAdmin/P' data3.txt 
On Tuesday, the Linux System
```

来看一下sed的用户手册是怎样说明 `D` 命令的：

> If pattern space contains no newline, start a normal new cycle as if the d command was issued.   Other‐wise,  delete  text  in the pattern space up to the first newline, and restart cycle with the resultant pattern space, without reading a new line of input.
补充：`d` 命令的用户手册说明
>>  d Delete pattern space.  Start next cycle.

(还是得看手册，终于解决了困惑。)

当出现多行匹配时，匹配命令只打印模式空间中的第一行。该命令的强大之处在于其和 `N` 命令以及和 `D` 命令配合使用的时候。  
`D` 命令的独特之处在于其删除模式空间的第一行之后，会强制sed编辑器返回到脚本的起始处（在模式空间中含有新行的情况下，如果不含有新行则会开启新的循环，我觉得书上说的有误，所以补充了这句），对当前模式空间的内容重新执行此循环（`D` 命令不会从数据流中读取新行）。在脚本中加入 `N` 命令，就能单步扫过(single-step through)整个模式空间，对多行进行匹配。接下来，先使用 `P` 命令打印第一行，然后使用 `D` 命令删除第一行并绕回到脚本的起始处，接着 `N` 命令会读取下一行文本并重新开始此过程。这个循环会一直持续到数据流结束。

```bash
lxc@Lxc:~/scripts/ch21$ cat corruptData.txt 
Header Line#
@
Data Line #1
Data Line #2#
@
End of Data Lines#
@
lxc@Lxc:~/scripts/ch21$ sed -n '
N
s/#\n@//
P
D
' corruptData.txt
Header Line
Data Line #1
Data Line #2
End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed -n '
N
s/#\n@//
p
D
' corruptData.txt
Header Line
Data Line #1
Data Line #2#
Data Line #2
End of Data Lines
```

*corruptData.txt* 是一个被破坏的数据文件，在一些行的末尾有 #符号，接着在下一行有 *@*。为了解决这个问题，可以使用sed将 *Header Line#* 行载入模式空间，然后用 `N` 命令载入第二行 *@*，将其附加到模式空间内的第一行之后。替换命令用空值来替换删除违规数据(#\n@)，然后 `P` 命令打印模式空间中已经清理过的第一行。`D` 命令将第一行从模式空间中删除。因为模式空间中不含有新行，所以本次循环结束。下次循环，sed编辑器读入下一行 *Data Line #1*，然后 `N` 命令读入下一行 *Data Line #2#*，替换命令模式不匹配，`P` 命令打印第一行 *Data Line #1*，然后 `D` 命令删除第一行，因为模式空间仍存有新行，所以重新开始此次循环。`N` 命令读入下一行 *@*，模式空间中存在的行匹配替换命令的模式，替换后，注意替换命令删除了匹配的模式，`P` 命令打印第一行 *Data Line #2*，`D`命令删除第一行。因为此时模式空间为空，所以本轮循环结束。sed编辑器开始下次循环，读入新行 *End of Data Lines#*，`N` 命令读入新行 *@* 附加到模式空间，替换命令模式匹配，`P` 命令打印处理后的第一行 *End of Data Lines*，`D` 命令删除该行，之后模式空间为空，本次循环结束，数据流也已读取完毕，sed编辑器退出。

## 2. 保留空间

**模式空间(pattern space)** 是一块活跃的缓冲区，在sed编辑器执行命令时保存着带检查的文本，但它并不是sed编辑器保存文本的唯一空间。
sed编辑器还有另一块称作 **保留空间(hold space)** 的缓冲区。当你在处理模式空间中的某些行时，可以用保留空间临时保存部分行。与保留空间相关的命令有5个，如下表所示：

|命令|描述|
| :--: | :----------------: |
|*h*|将模式空间复制到保留空间|
|*H*|将模式空间追加到保留空间|
|*g*|将保留空间复制到模式空间|
|*G*|将保留空间追加到模式空间|
|*x*|交换模式空间和保留空间的内容|

通常，使用 `h` 或 `H` 命令将字符串移入到保留空间之后，最终还要使用 `g`、`G` 或 `x` 命令将保存的字符串移回模式空间。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch21$ sed -n '/First/ {
> h;p;
> n;p;
> g;p}
> ' data2.txt
First Data Line
Second Data Line
First Data Line
```

我们来一步一步讲解这段代码。

1. sed脚本使用正则表达式作为地址，过滤出含有单词 *First* 的行。
2. 当出现含有单词 *First* 的行时，{} 中的第一个命令 `h` 会将该行复制到保留空间（保留空间的默默认值是一个空行，后续会讲到，）。这时，模式空间和保留空间的内容是一样的。
3. `p` 命令会打印模式空间的内容（First Data Line），也就是被复制进保留空间中的那一行。
4. `n` 命令会读取数据流中的下一行（Second Data Line），将其放入模式空间，注意与 `N` 命令将新内容附加到模式空间中已有内容之后不同，`n` 命令放入的内容会覆盖模式空间中的内容。现在模式空间和保留空间的内容不一样了。
5. `p` 命令会打印模式空间的内容（Second Data Line）。
6. `g` 命令会将保留空间的内容放回模式空间，替换模式空间的当前文本。模式空间和保留空间的内容现在又相同了。
7. `p` 命令会打印模式空间的当前行(First Data Line)。

## 3. 排除命令

第19章展示过sed编辑器如何将命令应用于数据流中的每一行或是由单个地址或地址区间指定的多行。我们也可以指示命令 **不应用于** 数据流中的特定地址或地址区间。
感叹号(!)命令用于排除(negate)命令，也就是让原本会起作用的命令失效。

```bash
lxc@Lxc:~/scripts/ch21$ sed -n '/Header/!p' data2.txt 
First Data Line
Second Data Line
End of Data Lines
```

正常的 `p` 命令只打印 *data2.txt* 文件中包含单词 *Header* 的那一行。加了感叹号之后，情况反过来了，除了包含单词 *Header* 的那一行，文件中的其他行都被打印。

[21.1.1](./README.md#2-合并文本行)节展示过一种情况，sed编辑器无法处理数据流中的最后一行文本，因为之后再没有其他行了。也可以用感叹号来解决这个问题：

```bash
lxc@Lxc:~/scripts/ch21$ cat data4.txt 
On Tuesday, the Linux System
Admin group meeting will be held.
All System Admins should attend.
lxc@Lxc:~/scripts/ch21$ sed '$!N;
> s/System\nAdmin/DevOps\nEngineer/
> s/System Admin/DevOps Engineer/
> ' data4.txt
On Tuesday, the Linux DevOps
Engineer group meeting will be held.
All DevOps Engineers should attend.
```

在该例中，当sed编辑器读到最后一行时，不执行 `N` 命令，但会对其他行执行 `N` 命令。
这种方法可以反转数据流中文本行的先后顺序。要实现这种效果，需要利用保留空间做一些特别的工作。
为此，可以使用sed做以下工作：

1. 在模式空间放置一行文本
2. 将模式空间中的文本复制到保留空间。
3. 在模式空间中放置下一行文本。
4. 将保留空间中的内容附加到模式空间。
5. 将模式空间的所有内容复制到保留空间。
6. 重复执行第3～5步，直到将所有文本行以反序放入保留空间。
7. 提取并打印文本行

在使用这种方法时，你不想在处理行的时候打印。这意味你要使用sed的 `-n` 选项。然后要决定如何将保留空间的内容附加到模式空间的文本之后。这可以使用 `G` 命令实现。唯一的问题是你不想将保留空间的文本附加到要处理的第一行文本之后。这可以使用感叹号命令轻松搞定：

```bash
1!G
```

接下来就是将新的模式空间（包含已反转的行）放入保留空间。这也不难，用 `h` 命令即可。
将模式空间的所有文本都反转之后，只需打印结果。当到达数据流中的最后一行时，你就得到了模式空间所有内容。要打印结果，可以使用如下命令：

```bash
$p
```
以上就是创建可以反转文本行的sed编辑器脚本所需要的操作步骤。

```bash
lxc@Lxc:~/scripts/ch21$ cat data2.txt 
Header Line
First Data Line
Second Data Line
End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed -n '{1!G; h; $p}' data2.txt 
End of Data Lines
Second Data Line
First Data Line
Header Line
```

> 有一个现成的bash shell命令可以实现同样的效果：`tac` 命令会以倒序显示文本文件。这个命令的名字也很奇妙，因为它的功能正好和 `cat` 命令相反，所以也采用了相反的命令。

## 4. 改变执行流程

通常，sed编辑器会从脚本的顶部开始，一直执行到脚本的结尾（`D` 命令是个例外，它会强制sed编辑器在不读取新行的情况下返回到脚本的顶部）。sed编辑器提供了一种方法，可以改变脚本的执行流程，其效果与结构化编程类似。

### *1. 分支*

sed编辑器还提供了一种方法，这种方法可以基于地址、地址模式或地址区间排除一整段命令。这允许你只对数据流中的特定部分执行命令。

*分支命令格式如下：*

```bash
[address] b[label]
```

*address* 参数决定了哪些行会触发命令。*label* 参数定义了要跳转到位置。如果没有 *label* 参数，则跳过触发分支命令的行，继续处理余下的文本。

下面这个例子使用了分支命令的 *address* 参数，但未指定 *label*：

```bash
lxc@Lxc:~/scripts/ch21$ cat data2.txt 
Header Line
First Data Line
Second Data Line
End of Data Lines
lxc@Lxc:~/scripts/ch21$ sed '{2,3b
> s/Line/Replacement/
> }' data2.txt
Header Replacement
First Data Line
Second Data Line
End of Data Replacements
```

如你所见，分支命令在第2、3行跳过了替换命令。

如果不想跳转到脚本末尾，可以定义 *label* 参数，指定分支命令要跳转到的位置。标签以冒号开始，最多可以有7个字符：

```bash
:label2
```

要指定 *label*，把它放在分支命令之后即可。有了标签，就可以使用其他命令处理匹配分支 *address* 的那些行。对于其他行，仍然沿用脚本中原先的命令处理。

```bash
lxc@Lxc:~/scripts/ch21$ sed '{/First/b jump1;
> s/Line/Replacement/
> :jump1
> s/Line/Jump Replacement/
> }' data2.txt
Header Replacement
First Data Jump Replacement
Second Data Replacement
End of Data Replacements
```

分支命令指定，如果文本行中出现 *First*，则程序应该跳转到标签为 *jump1* 的脚本行。如果文本行不匹配分支 *address*，则sed编辑器会继续执行脚本中的命令，包括标签 *jump1* 之后的命令。（因此，两个替换命令都被应用于不匹配分支 *address* 的行。当然，在第一个替换命令将 *Line* 替换成 *Replacement* 之后，第二个替换命令就不能匹配到 *Line* 的模式了）。如果某行匹配分支 *address*，那么sed编辑器就会跳转到带有分支标签 *jump1* 的那一行，因此只有最后一个替换命令会被执行。

这个例子演示了跳转到sed脚本下方的标签。你也可以像下面这样，跳转到靠前的标签，达到循环的效果：

```bash
lxc@Lxc:~/scripts/ch21$ echo "This, is, a, test, to, remove, commas." |
> sed -n {'
> :start
> s/,//1p
> b start
> }'
This is, a, test, to, remove, commas.
This is a, test, to, remove, commas.
This is a test, to, remove, commas.
This is a test to, remove, commas.
This is a test to remove, commas.
This is a test to remove commas.
^C
```

脚本每次迭代都会删除文本中的第一个逗号并打印字符串。这个脚本有一个问题。永远不会结束。这就形成一个死循环，不停的查找逗号，直到使用 Ctrl+C 组合键发送信号，手动停止脚本。

为了避免这种情况，可以为分支命令指定一个地址模式。如果模式不匹配，就不会再跳转：

```bash
lxc@Lxc:~/scripts/ch21$ echo "This, is, a, test, to, remove, commas." | 
> sed -n '{
> :start
> s/,//1p
> /,/b start
> }'
This is, a, test, to, remove, commas.
This is a, test, to, remove, commas.
This is a test, to, remove, commas.
This is a test to, remove, commas.
This is a test to remove, commas.
This is a test to remove commas.
```

现在分支命令只会在行中有逗号的情况下跳转。在最后一个逗号被删除后，分支命令不再执行，脚本结束。

### *2. 测试*

与分支命令类似，测试（t）命令也可以改变sed编辑器脚本的执行流程。测试命令会根据先前替换命令的结果跳转到某个 *label* 处，而不是根据 *address* 进行跳转。  
如果替换命令成功匹配并完成了替换，测试命令就会跳转到指定的标签。如果替换命令未能匹配指定的模式，测试命令就不会跳转。

*测试命令的格式与分支命令相同：*

```bash
[address]t [label]
```

跟分支命令一样，在没有指定 *label* 的情况下，如果测试成功，sed会跳转到脚本结尾。

测试命令提供了一种低成本的方法来对数据流中的文本执行 *if-then* 语句。如果需要做二选一的替换操作，也就是执行这个替换就不执行另一个替换，那么测试命令可以助你一臂之力（无须指定 *label*）：

```bash
lxc@Lxc:~/scripts/ch21$ sed '{s/First/Matched/; t
> s/Line/Replacement/
> }' data2.txt
Header Replacement
Matched Data Line
Second Data Replacement
End of Data Replacements
```

第一个替换命令会查找模式文本 *First*。如果匹配了行中的模式，就替换文本，而且测试命令会跳过后面的替换命令。如果第一个替换未能匹配，则执行第二个替换命令。

有了替换命令，就能避免之前用分支命令形成的死循环：

```bash
lxc@Lxc:~/scripts/ch21$ echo "This, is, a, test, to, remove, commas." | 
> sed -n '{
> :start
> s/,//1p
> t start
> }' 
This is, a, test, to, remove, commas.
This is a, test, to, remove, commas.
This is a test, to, remove, commas.
This is a test to, remove, commas.
This is a test to remove, commas.
This is a test to remove commas.
```

当没有逗号可以替换时，测试命令不再跳转，而是继续执行剩下的脚本（在本例中，也就是结束脚本）。

## 5. 模式替换

加入你想为行中匹配的单词加上引号。如果只是要匹配某个单词，那非常简单：

```bash
lxc@Lxc:~/scripts/ch21$ echo "The cat sleeps in his hat" |
> sed 's/cat/"cat"/'
The "cat" sleeps in his hat
```

但如果在模式中用点号来匹配多个单词呢？

```bash
lxc@Lxc:~/scripts/ch21$ echo "The cat sleeps in his hat." |  sed 's/.at/".at"/g'
The ".at" sleeps in his ".at".
```

结果并不如意，下面介绍解决方法。

### *1. `&`符号*

sed编辑器提供了一种解决方法。`&` 符号可以代表替换命令中的匹配模式。不管模式匹配到的是什么样的文本，都可以使用 `&` 符号代表这部分内容。这样就能处理匹配模式的任何单词了:

```bash
lxc@Lxc:~/scripts/ch21$ echo "The cat sleeps in his hat." | sed 's/.at/"&"/g'
The "cat" sleeps in his "hat".
```

### *2. 替换单独的单词*

`&` 符号代表替换命令中指定模式所匹配的字符串。但有时候，你只想获取该字符串的一部分。当然可以这样做，不过有点难度。  
sed编辑器使用圆括号来定义替换模式中的子模式。随后使用特殊的字符串来引用（称作 **反向引用(back reference)**）每个子模式所匹配到的文本。反向引用由反斜线和数字组成。数字表明子模式的符号，第一个子模式为 `\1`，第二个子模式为 `\2`，以此类推。

> **注意：**，在替换命令中使用圆括号时，必须使用转义字符，以此表明这不是普通的圆括号，而是用于划分子模式。这跟转义其他特殊字符正好相反。

*来个反向引用的例子：*

```bash
lxc@Lxc:~/scripts/ch21$ echo "The Guide to Programming" |  sed '
s/\(Guide to\) Programming/\1 DevOps/'
The Guide to DevOps
```

这个替换命令将 *Guide to* 放入圆括号，将其标示为一个子模式。然后使用 `\1` 来提取此子模式匹配到的文本。

如果需要用一个单词来替换一个短语，而这个单词又正好是该短语的子串，但在子串中用到了特殊的模式字符，那么这时使用子模式将会方便很多：

```bash
lxc@Lxc:~/scripts/ch21$ echo "That furry cat is pretty." |
> sed 's/furry \(.at\)/\1/'
That cat is pretty.
```

在这种情况下，不能用 `&` 符号，因为其代表的是整个模式所匹配到的文本。而反向引用则允许将某个子模式匹配到的文本作为替换内容。

当需要在两个子模式间插入文本时，这个特性尤其有用。下面的脚本使用子模式在大数中插入逗号：

```bash
lxc@Lxc:~/scripts/ch21$ echo "1234567" |
> sed '{
> :start
> s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/
> t start}'
1,234,567
```

这个脚本将匹配模式分成了两个子模式：

- .*[0-9]
- [0-9]{3}

sed编辑器会在文本行中查找这两个子模式。第一个子模式是以数字结尾的任意长度字符串。第二个子模式是3位数字。如果匹配到了相应的模式，就在两者之间加一个逗号，每个子模式都通过其序号来标示。这个脚本使用测试命令来遍历这个大数，直到所有的逗号都插入完毕。

## 6. 在脚本中使用sed

本节将演示一些你应该已经知道的一些特性，在bash shell脚本中使用sed编辑器时能够用到它们。

### *1. 使用包装器*

编写sed脚本的过程很烦琐，尤其是当脚本很长的时候。你可以将sed编辑器命令放入脚本 **包装器**。这样就不用每次都重新键入整个脚本。包装器充当着sed编辑器脚本和命令行之间的中间人的角色。shell脚本包装器 [ChangeScriptShell.sh](../ch19/ChangeScriptShell.sh) 在第19章的时候作为实例出现过。

*来个例子：*

[reverse.sh](./reverse.sh)

```bash
#!/bin/bash
# Shell wrapper for sed editor script
# to reverse test file lines.
# 
sed -n '{1!G; h; $p}' $1
# 
exit
# output:
lxc@Lxc:~/scripts/ch21$ cat data2.txt 
Header Line
First Data Line
Second Data Line
End of Data Lines
lxc@Lxc:~/scripts/ch21$ ./reverse.sh data2.txt 
End of Data Lines
Second Data Line
First Data Line
Header Line
```

### *2. 重定向sed的输出*

在shell脚本中，你可以用 *命令替换* 来将sed编辑器命令的输出重定向到一个变量中，以备后用。

[fact.sh](./fact.sh)

```bash
#!/bin/bash
# Shell wrapper for sed editor script
# to calaulate a factorial, and
# format the result with commas.
# 
factorial=1
counter=1
number=$1
# 
while [ $counter -le $number ]
do
    factorial=$[ $factorial * $counter ]
    counter=$[ $counter + 1 ]
done
# 
result=$(echo $factorial | 
sed '{
:start
s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/
t start
}')
#
echo "The result is $result"
# 
exit
# output:
lxc@Lxc:~/scripts/ch21$ ./fact.sh 20
The result is 2,432,902,008,176,640,000
```

## 7. 创建sed实用工具

本节将展示一些方便趁手且众所周知的sed编辑器脚本，从而帮助你完成常见的数据处理工作。

### *1. 加倍行间距*

首先，来看一个向文本文件的行间插入空行的简单sed脚本。

```bash
lxc@Lxc:~/scripts/ch21$ sed 'G' data2.txt 
Header Line

First Data Line

Second Data Line

End of Data Lines

```

这个技巧的关键在于保留空间的默认值。`G` 命令只是将保留空间的内容附加到模式空间内容之后。当启动sed编辑器时，保留空间只有一个空行。将它附加到已有行之后，就创建了空行。但是，在最后一行之后我们也插入了空行，我们可以使用排除命令来确保脚本不会将空行插入到数据流的最后一行之后。

```bash
lxc@Lxc:~/scripts/ch21$ sed '$!G' data2.txt 
Header Line

First Data Line

Second Data Line

End of Data Lines
```

### *2. 对可能含有空行的文件加倍行间距*

将上面的例子再扩展一步，如果文本文件已经有一些空行，但你想给所有行加倍行间距(即每个行除最后一行外后面只有一个空行)，如果沿用前面的脚本，则有些区域会有太多空行，因为已的空行也会被加倍(即空行也被算作一行，空行后面还会再放入空行)。

```bash
lxc@Lxc:~/scripts/ch21$ cat data6.txt 
Line one.
Line two.

Line three.
Line four.
lxc@Lxc:~/scripts/ch21$ sed '$!G' data6.txt 
Line one.

Line two.



Line three.

Line four.
```

原来是有一个空行的的位置现在有3个空行了。解决办法是先删除所有空行，再在每行除最后一行外再插入空行。

```bash
lxc@Lxc:~/scripts/ch21$ sed '/^$/d; $!G' data6.txt 
Line one.

Line two.

Line three.

Line four.
```

### *3. 给文件中的行编号*

第 [19](../ch19/README.md#2-打印行号) 章演示过如何使用等号来显示数据流中行的行号：

```bash
lxc@Lxc:~/scripts/ch21$ sed '=' data2.txt 
1
Header Line
2
First Data Line
3
Second Data Line
4
End of Data Lines
```

这多少有点难看。

解决方法如下：

```bash
lxc@Lxc:~/scripts/ch21$ sed '=' data2.txt | sed 'N; s/\n/ /'
1 Header Line
2 First Data Line
3 Second Data Line
4 End of Data Lines
```

使用 `N` 命令合并行，使用替换命令将换行符替换成空格或者制表符，不再赘述。

有些bash shell命令也能添加行号。但是会引入一些额外的(可能是不需要的)间隔：

```bash
lxc@Lxc:~/scripts/ch21$ nl data2.txt 
     1  Header Line
     2  First Data Line
     3  Second Data Line
     4  End of Data Lines
lxc@Lxc:~/scripts/ch21$ cat -n data2.txt 
     1  Header Line
     2  First Data Line
     3  Second Data Line
     4  End of Data Lines
lxc@Lxc:~/scripts/ch21$ nl data2.txt | sed 's/     //; s/\t/ /'
1 Header Line
2 First Data Line
3 Second Data Line
4 End of Data Lines
# 在sed编辑器命令中第一个替换是5个空格。
```

### *4. 打印末尾行*

本节展示使用滑动窗口的方法来显示数据流末尾的若干行。

```bash
lxc@Lxc:~/scripts/ch21$ cat data7.txt
Line1
Line2
Line3
Line4
Line5
Line6
Line7
Line1
Line2
Line3
Line4
Line5
Line6
Line7
Line8
Line9
Line10
Line11
Line12
Line13
Line14
Line15
lxc@Lxc:~/scripts/ch21$ sed '{
> :start
> $q; N; 11,$D
> b start
> }' data7.txt
Line6
Line7
Line8
Line9
Line10
Line11
Line12
Line13
Line14
Line15
```

该脚本首先检查当前行是否是数据流中的最后一行。如果是，则退出命令( `q` )会停止循环，`N` 命令会将下一行附加到模式空间中的当前行之后。如果当前行在第10行之后，则 `11,$D` 命令会删除模式空间中的第1行。这就在模式空间创建了类似滑动窗口的效果。因此，这个sed脚本只会显示 *data7.txt* 文件的最后10行。

### 5. 删除行

本节给出了3个简洁的sed编辑器脚本，用来删除数据中不需要的空行。

#### *1. 删除连续的多行*

删除连续空行的关键在于创建包含一个空行和非空行的地址空间。如果sed编辑器遇到了这个区间，它不会删除行。但对于不属于该区间的行（两个或者多个空行），则执行删除操作。

下面是完成该操作的脚本：

```bash
/./,/^$/!d
```

该命令使用了两个模式匹配，第一个模式匹配作为地址区间的起始地址，第二个模式匹配作为地址区间的结束地址。指定的区间是 `/./` 到 `/^$/`。区间的开始地址会匹配至少含有一个字符的行。区间的结束地址会匹配一个空行。然后使用了排除命令，在这个区间内的行不会被删除。

```bash
lxc@Lxc:~/scripts/ch21$ cat data8.txt 
Line one.


Line two.

Line three.



Line four.
lxc@Lxc:~/scripts/ch21$ sed '/./,/^$/!d' data8.txt 
Line one.

Line two.

Line three.

Line four.
```

如你所见，不管文件的数据行之间有多少空行，在输出中只保留一个空行。

#### *2. 删除开头的空行*

该脚本用于删除数据流中开头的空行。

```bash
lxc@Lxc:~/scripts/ch21$ cat data9.txt


Line one.

Line two.
lxc@Lxc:~/scripts/ch21$ sed '/./,$!d' data9.txt 
Line one.

Line two.
```

该脚本使用模式匹配作为地址区间的起始地址，`$` 为地址区间的结束地址。

#### *3. 删除结尾的空行*

删除结尾的空行不像删除开头的空行那么简单。要利用循环实现：

```bash
lxc@Lxc:~/scripts/ch21$ cat data10.txt 
Line one.
Line two.



lxc@Lxc:~/scripts/ch21$ sed '{
> :start
> /^\n*$/{$d; N; b start}
> }' data10.txt
Line one.
Line two.
```

在该脚本中，`/^\n*$/` 这是一个模式匹配，其中用到了[组合锚点](../ch20/README.md#3-组合锚点)。该组合锚点是想匹配这样的一行：以 0个或多个(星号)(实际上一行最多一个换行符嘛)以 `\n` 开头和结尾的行(0个换行符就是最后一行空行，1个换行符就是最后一行空行之前的空行)。分支命令使用了地址模式，见[分支](./README.md#1-分支)的最后部分。 如果模式匹配，如果是最后一行则执行 `d` 命令，删除模式空间中的行。如果不是最后一行那么 `N` 命令会将下一行附加到它后面，然后分支命令跳转到循环开始处重新开始。

该脚本成功删除了文本文件结尾的空行，同时保持了其他空行未变。

### *6. 删除HTML标签*

如题，删除HTML标签，大多数HTML标签是成对出现的：一个起始标签(比如\<b>用来加粗)和一个闭合标签(比如\</b>用来结束加粗)。

乍一看，你可能认为删除HTML标签就是查找以小于号(<)开头、大于号(>)结尾且其中包含数据的字符串:

```bash
s/<.*>//g
```

但这个命令可能会造成一些意想不到的结果：

```bash
lxc@Lxc:~/scripts/ch21$ sed 's/<.*>//g' data11.txt 






This is the  line in the Web page.
This should provide some 
information to use in our sed script.


```
注意标题文本以及加粗和倾斜的文本都不见了。sed编辑器忠实地将这个脚本理解为小于号和大于号之间的任何文本，包括前者的小于号和后者的大于号(因为 `*` 属于贪婪型量词)。为此，要让sed编辑器忽略任何嵌入原始标签中的大于号。可以使用[排除型字符组](../ch20/README.md#6-排除型字符组)来排除大于号，将脚本改为如下形式：

```bash
s/<[^>]*>//g
```

现在这个脚本就能正常显示Web页面中的数据了：

```bash
lxc@Lxc:~/scripts/ch21$ sed 's/<[^>]*>//g' data11.txt 


This is the page title



This is the first line in the Web page.
This should provide some useful
information to use in our sed script.


```

可以删除多余的空行来使结果更清晰：

```bash
lxc@Lxc:~/scripts/ch21$ sed 's/<[^>]*>//g; /^$/d' data11.txt 
This is the page title
This is the first line in the Web page.
This should provide some useful
information to use in our sed script.
```

## 8. 实战演练

搞一个脚本，该脚本扫描bash shell脚本，找出适合放入函数的一些重复行。

[NeededFunctionCheck.sh](./NeededFunctionCheck.sh)

```bash
#!/bin/bash
# Checks for 3 duplicate lines in scripts.
# Suggest these lines are possible replaced
# by a function.
# 
tempfile=$2
# 
# 
sed -n '{
1N; N;
s/ //g; s/\t//g;
s/\n/\a/g; p;
s/\a/\n/; D}' $1 >> $tempfile
# 
sort $tempfile | uniq -d | sed 's/\a/\n/g'
# 
rm -i $tempfile
# 
exit
# output:
lxc@Lxc:~/scripts/ch21$ ./NeededFunctionCheck.sh ScriptDataB.txt TempFile.txt
Line3
Line4
Line5
rm：是否删除普通文件 'TempFile.txt'？ y
lxc@Lxc:~/scripts/ch21$ ./NeededFunctionCheck.sh CheckMe.sh TempFile.txt
echo"Usage:./CheckMe.shparameter1parameter2"
echo"Exitingscript..."
exit
rm：是否删除普通文件 'TempFile.txt'？ y
```