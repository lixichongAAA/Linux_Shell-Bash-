# ch20 正则表达式

本章将介绍如何在sed和gawk中创建正则表达式，以得到所需要的数据。

## 1. 正则表达式基础

### *1. 定义*

正则表达式是一种可供Linux工具过滤文本的自定义模板。Linux工具（比如sed和gawk）会在读取数据时使用正则表达式对数据进行模式匹配。如果数据匹配模式，它就会被接受并进行处理。如果数据不匹配模式，它就会被弃用。
正则表达式使用元字符（原书中使用的是 wildcard character(通配符)，准确的说，通配符和正则表达式并不是一回事，虽然正则表达式中也有 `*` 和 `?`，但是作用完全不一样。）来描述数据流中的一个或多个字符。
Linux中很多场景使用特殊字符来描述具体内容不确定的数据。比如在 `ls` 命令中使用通配符列出文件和目录（准确的过程是这样的：shell负责处理通配符，在本例中，将 *\*.sh*扩展为当前目录下以 *.sh* 结尾的所有文件名，`ls` 命令会列出由通配符匹配的那些文件信息。**通配符是由shell处理的，命令看到的只是经过处理后的匹配结果**） 

```bash
lxc@Lxc:~/scripts/ch20$ ls -al *.sh
-rwxrw-r-- 1 lxc lxc 324 11月 15 20:37 countfiles.sh
-rwxrw-r-- 1 lxc lxc 146 11月 15 21:41 isemail.sh
-rwxrw-r-- 1 lxc lxc 139 11月 15 21:03 isphone.sh
```

正则表达式的工作方式与通配符类似。正则表达式包含文本和/或特殊字符（这些特殊字符在正则表达式中称作 **元字符(metacharacter)**），定义了sed和gawk匹配时使用的模板。你可以在正则表达式中使用不同的特殊字符来第一特定的数据过滤模式。

### *2. 正则表达式的类型*

使用正则表达式最大的问题在于不止一种类型的正则表达式。在Linux中，不同的应用程序可能使用不同类型的正则表达式。
正则表达式是由 **正则表达式引擎** 实现的。这是一种底层软件，负责解释正则表达式并用这些模式进行文本匹配。
尽管在Linux世界有很多不同的正则表达式引擎，但最流行的是以下两种：

- POSIX基础正则表达式(basic regular expression，BRE)引擎。
- POSIX扩展正则表达式(extended regular expression，ERE)引擎。

大多数Linux工具至少符合POSIX BRE引擎规范，能够识别该规范定义的所有模式符号。有些工具（比如sed）仅符合BRE引擎规范的一个子集，这是出于速度方面的考虑导致的，因为sed希望尽可能快的处理数据流中的文本。POSIX ERE引擎多见于依赖正则表达式过滤文本的编程语言中。它为常见模式（比如数字、单词、以及字母数字字符）提供了高级模式符号和特殊符号。gawk使用ERE引擎来处理正则表达式。

## 2. 定义BRE模式

最基本的BRE模式是匹配数据流中的文本字符。本节将介绍在正则表达式中定义文本的方法及其预期的匹配结果。

### *1. 普通文本*

正则表达式区分大小写，它只会匹配大小写也相符的模式。

```bash
lxc@Lxc:~/scripts/ch20$ echo "This is a test" | sed -n '/This/p'
This is a test
lxc@Lxc:~/scripts/ch20$ echo "This is a test" | sed -n '/this/p'
lxc@Lxc:~/scripts/ch20$ 
```

在正则表达式中无须写出整个单词。只要定义的文本出现在数据流中，正则表达式就能够匹配。

```bash
lxc@Lxc:~/scripts/ch20$ echo "The books are expensive" | sed -n '/book/p'
The books are expensive
```

尽管数据流中文本是 *books*，但数据中含有正则表达式 *book*，因此正则表达式能匹配数据。当然，反过来就不行了。

```bash
lxc@Lxc:~/scripts/ch20$ echo "The book is expensive" | sed -n '/books/p'
lxc@Lxc:~/scripts/ch20$ 
```

你也无须在正则表达式中只使用单个文本单词，空格和数字也是可以的。在正则表达式中，空格和其他字符没有什么区别。

```bash
lxc@Lxc:~/scripts/ch20$ echo "This is line number 1" | sed -n '/ber 1/p'
This is line number 1
```

如果正则表达式中定义了空格，那么它必须出现在数据流中。你甚至可以创建匹配多个连续空格的正则表达式：

```bash
lxc@Lxc:~/scripts/ch20$ cat data1 
This is a normal line of text.
This is  a line with too many spaces.
lxc@Lxc:~/scripts/ch20$ sed -n '/  /p' data1
This is  a line with too many spaces.
```

### *2. 特殊字符*

正则表达式中的一些字符具有特别的含义。正则表达式能识别的特殊字符如下所示：

`.*[]^${}\+?|()`

如果要将某个特殊字符视为普通字符，则必须将其转义，需要在其前面加个反斜线。

*来几个例子：*

```bash
lxc@Lxc:~/scripts/ch20$ cat data2 
The cost is $4.00
lxc@Lxc:~/scripts/ch20$ sed -n '/\$/p' data2
The cost is $4.00
```

```bash
lxc@Lxc:~/scripts/ch20$ echo "\ is a special character" | sed -n '/\\/p'
\ is a special character
```

尽管正斜线不是正则表达式中的特殊字符，但在sed或gawk正则表达式中要用到它一样也要转义。

```bash
lxc@Lxc:~/scripts/ch20$ echo "3 / 2" | sed -n '/\//p'
3 / 2
```

### 3. 锚点字符

在默认情况下，当指定一个正则表达式模式时，只要模式出现在数据流中的任何地方，它就能匹配。有两个特殊字符可以用来将模式锁定在数据流中的行首或行尾。

#### *1. 锚定行首*

脱字符(^)可以指定位于数据流中文本行行首的模式。如果模式出现在行首之外的位置，则正则表达式无法匹配。要使用脱字符，就必须将其置于正则表达式之前：

```bash
lxc@Lxc:~/scripts/ch20$ echo "The book store" | sed -n '/^book/p'
lxc@Lxc:~/scripts/ch20$ echo "Books are great" | sed -n '/^Book/p'
Books are great
```

脱字符使得正则表达式引擎在每行（由换行符界定）的行首检查模式：

```bash
lxc@Lxc:~/scripts/ch20$ cat data3
This is a test line.
this is another test line.
A line that tests this feature.
Yet more testing of this
lxc@Lxc:~/scripts/ch20$ sed -n '/^this/p' data3 
this is another test line.
```

如果将脱字符放在正则表达式开头之外的位置，那么它就跟普通字符一样，没什么特殊含义了。

```bash
lxc@Lxc:~/scripts/ch20$ echo "This ^ is a test" | sed -n '/s ^/p'
This ^ is a test
```

如果正则表达式中只有脱字符，就不必用反斜线转义。但如果在正则表达式中先指定脱字符，随后还有其他文本，那就必须在脱字符前用转义字符：

```bash
lxc@Lxc:~/scripts/ch20$ echo "This ^ is a test" | sed -n '/s ^/p'
This ^ is a test
lxc@Lxc:~/scripts/ch20$ echo "This ^ is a test" | sed -n '/^/p'
This ^ is a test
# 注意看这个示例，如果正则表达式中只有脱字符就不必用反斜线转义。

lxc@Lxc:~/scripts/ch20$ echo "I love ^regex" | sed -n '/\^regex/p'
I love ^regex
# 但如果在正则表达式中先指定脱字符，随后还有其他文本，那就必须在脱字符前用转义字符。这也相当容易理解
# 因为你不转义，那不就又成了锚定行首了嘛，就变成了查找以...开头的模式。

lxc@Lxc:~/scripts/ch20$ echo "I love ^regex" | sed -n '/ ^/p'
I love ^regex
```

#### *2. 锚定行尾*

特殊字符美元符号($)定义了行尾锚点。将这个特殊字符放在正则表达式之后则表示数据行必须以该模式结尾。

```bash
lxc@Lxc:~/scripts/ch20$ echo "This is a good book" | sed -n '/book$/p'
This is a good book
lxc@Lxc:~/scripts/ch20$ echo "This book is good" | sed -n '/book$/p'
```

使用该模式时，你必须清楚到底要查什么：

```bash
lxc@Lxc:~/scripts/ch20$ echo "There are a lot of books" | sed -n '/$book/p'
lxc@Lxc:~/scripts/ch20$ 
```

尽管 *book* 这个模式确实存在于数据文本中，但该数据文本并不是以 *book* 的模式结尾的，所以不匹配。

#### *3. 组合锚点*

我们可以在同一行中组合使用行首锚点和行尾锚点。比如，我们要查找只含有特定文本模式的数据行：

```bash
lxc@Lxc:~/scripts/ch20$ cat data4 
this is a test of using both anchors
I said this is a test
this is a test
I'm sure this is a test.
lxc@Lxc:~/scripts/ch20$ sed -n '/^this is a test$/p' data4 
this is a test
```

我们可以直接将这两个锚点组合在一起，之间不加任何文本。这样可以过出数据流中的空行。

```bash
lxc@Lxc:~/scripts/ch20$ cat data5 
This is one test line.


This is another test line.
lxc@Lxc:~/scripts/ch20$ sed '/^$/d' data5
This is one test line.
This is another test line.
# 我们先过滤出了空行，然后删除了空行。所以输出中没有空行。
```

### *4. 点号字符*

**点号字符可以匹配除换行符之外的任意单个字符**。点号必须匹配一个字符，如果点号字符的位置没有可匹配的字符，那么模式不成立。

```bash
lxc@Lxc:~/scripts/ch20$ cat data6
This is a test of a line.
The cat is sleeping.
That is a very nice hat.
This test is at line four.
at ten o'clock we'll go home.
lxc@Lxc:~/scripts/ch20$ sed -n '/.at/p' data6
The cat is sleeping.
That is a very nice hat.
This test is at line four.
# 最后一处匹配是空格匹配了点号字符。
```

### 5. *字符组*

点号字符在匹配某个位置上的任意字符时很有用，但如果你想限定要匹配的具体字符，可以使用 **字符组(character class)**。
你可以在正则表达式中定义用来匹配某个位置的一组字符。如果字符中的某个字符出现在了数据流中，那就能匹配该模式。方括号用于定义字符组。在方括号中加入你希望出现在该字符组中的所有字符，就可以在正则表达式中像其他特殊字符一样使用字符组了。

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/[ch]at/p' data6 
The cat is sleeping.
That is a very nice hat.
```

在这个例子中匹配这个模式的只有单词 *cat* 和 *hat* 。

在不确定某个字符的大小写时非常适合使用字符组，在单个正则表达式可以使用多个字符组：

```bash
lxc@Lxc:~/scripts/ch20$ echo "Yes" | sed -n '/[Yy]es/p'
Yes
lxc@Lxc:~/scripts/ch20$ echo "YEs" | sed -n '/[Yy][Ee][Ss]/p'
YEs
```

字符组中当然并非只能使用字母，也可以在其中使用数字：

```bash
lxc@Lxc:~/scripts/ch20$ cat data7 
This line doesn't contain a number.
This line has 1 number on it.
This line a number 2 on it.
This line has a number 4 on it.
lxc@Lxc:~/scripts/ch20$ sed -n '/[0123]/p' data7 
This line has 1 number on it.
This line a number 2 on it.
```

你也可以将多个字符组组合在一起，以检查数字是否具备正确的格式，比如电话号码和邮政编码。当你尝试匹配某种特定格式时，一定要注意。这里有个邮政编码匹配出错的例子：

```bash
lxc@Lxc:~/scripts/ch20$ cat data8 
60633
46201
223001
4353
22203
lxc@Lxc:~/scripts/ch20$ sed -n '/[1234567890][1234567890][1234567890][1234567890][1234567890]/p' data8 
60633
46201
223001
22203
```

在结果中，错误的保留了一个6位数的结果，尽管我们只定义了5个字符组。记住，正则表达式可以匹配数据流中任意位置的文本。匹配模式之外经常会有其他字符。如果想确保只匹配5位数，可以像下面那样，指明匹配数字的起止位置。

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/^[1234567890][1234567890][1234567890][1234567890][1234567890]$/p' data8
60633
46201
22203
```

字符组一种常见的用法是解析拼错的单词，比如用户表单输入的数据。

```bash
lxc@Lxc:~/scripts/ch20$ cat data9 
I need to have some maintenence done on my car.
I'll pay that in a seperate invoice.
After I pay for the maintenance my car will be as good as new.
lxc@Lxc:~/scripts/ch20$ sed -n '
> /maint[ea]n[ae]nce/p
> /sep[ea]r[ea]te/p
> ' data9
I need to have some maintenence done on my car.
I'll pay that in a seperate invoice.
After I pay for the maintenance my car will be as good as new.
```

两个sed打印命令利用正则表达式字符组来查找文本中拼错的单词 *maintenence* 和 *seperate*。同样的正则表达式也能匹配正确拼写的结果。

### *6. 排除型字符组*

在正则表达式中，你可以反转字符组的作用：匹配字符组中没有的字符。为此，只需在字符组的开头添加脱字符即可：

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/[^ch]at/p' data6
This test is at line four.
```

通过排除型字符组，正则表达式会匹配除 *c* 或 *h* 之外的任何字符以及文本模式。由于空格字符属于这个范围，因此通过了模式匹配。但即使是排除型，字符组必须匹配一个字符，以 *at* 为起始的行不能匹配模式。

### *7. 区间*

可以用单连字符在字符组中表示字符区间。只需指定区间的第一个字符、连字符以及区间的最后一个字符即可。根据Linux系统使用的字符集（参见第二章），字符组会包括此区间（闭区间）内的任意字符。

*来几个例子：*

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/^[0-9][0-9][0-9][0-9][0-9]$/p' data8 
60633
46201
22203
```

同样的方法也适用于字母。

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/[c-h]at/p' data6 
The cat is sleeping.
That is a very nice hat.
# 该模式只会匹配在字母 c 和 h 之间的单词。
# 在这种情况下，只含有单词 at 的行无法匹配该模式。 
```

还可以在单个字符组内指定多个不连续的区间：

```bash
lxc@Lxc:~/scripts/ch20$ sed -n '/[a-ch-m]at/p' data6 
The cat is sleeping.
That is a very nice hat.
# 字符组内指定了两个区间，a-c 以及 h-m。
```

### *8. 特殊的字符组*

除了定义自己的字符组，BRE还提供了一些特殊的字符组，以用来匹配特定类型的字符。下表列出了可用的BRE特殊字符组。

|字符组|描述|
| :-----------: | :------------------------------------------------------: |
|\[[:alpha:]]|匹配任意字母字符，无论是大写还是小写|
|\[[:alnum:]]|匹配任意字母数字字符，0-9、A-Z、a-z|
|\[[:blank:]]|匹配空格或制表符|
|\[[:digit:]]|匹配0-9中的数字|
|\[[:lower:]]|匹配小写字母字符a-z|
|\[[:print:]]|匹配任意可打印字符|
|\[[:punct:]]|匹配标点符号|
|\[[:space:]]|匹配任意空白字符:空格、制表符、换行符、分页符(formfeed)、垂直制表符和回车符|
|\[[:upper:]]|匹配任意大写字母字符A-Z|

特殊字符组在正则表达式中的用法和普通字符组一样：

```bash
lxc@Lxc:~/scripts/ch20$ echo "abc" | sed -n '/[[:digit:]]/p'
lxc@Lxc:~/scripts/ch20$ echo "abc" | sed -n '/[[:alpha:]]/p'
abc
lxc@Lxc:~/scripts/ch20$ echo "abc123" | sed -n '/[[:digit:]]/p'
abc123
lxc@Lxc:~/scripts/ch20$ echo "This, is, a test" | sed -n '/[[:punct:]]/p'
This, is, a test
```

### *9. 星号*

**在字符后面放置星号表明该字符必须在匹配模式的文本中出现0次或多次**

```bash
lxc@Lxc:~/scripts/ch20$ echo "ik" | sed -n '/ie*k/p'
ik
lxc@Lxc:~/scripts/ch20$ echo "iek" | sed -n '/ie*k/p'
iek
lxc@Lxc:~/scripts/ch20$ echo "ieek" | sed -n '/ie*k/p'
ieek
lxc@Lxc:~/scripts/ch20$ echo "ieeeeeeeek" | sed -n '/ie*k/p'
ieeeeeeeek
```

这个特殊符号广泛用于处理有常见拼写错误或在不同语言中有拼写变化的单词。比如：

```bash
lxc@Lxc:~/scripts/ch20$ echo "I am getting a color TV" | sed -n '/colou*r/p'
I am getting a color TV
lxc@Lxc:~/scripts/ch20$ echo "I am getting a colour TV" | sed -n '/colou*r/p'
I am getting a colour TV
```

如果一个单词经常被拼错也可以用星号来容忍这种错误。

```bash
lxc@Lxc:~/scripts/ch20$ echo "I ate a potatoe with my lunch" | sed -n '/potatoe*/p'
I ate a potatoe with my lunch
lxc@Lxc:~/scripts/ch20$ echo "I ate a potato with my lunch" | sed -n '/potatoe*/p'
I ate a potato with my lunch
```

可以将点号字符和星号字符组合起来。**这个组合能够匹配任意数量的任意字符**，通常用在数据流中两个可能相邻或不相邻的字符串之间：

```bash
lxc@Lxc:~/scripts/ch20$ echo "This is a regular pattern expression" | sed -n '/regular.*expression/p'
This is a regular pattern expression
```

星号还能用于字符组，指定可能在文本中出现0次或多次的字符组或字符区间：

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | sed -n '/b[ae]*t/p'
bt
lxc@Lxc:~/scripts/ch20$ echo "bat" | sed -n '/b[ae]*t/p'
bat
lxc@Lxc:~/scripts/ch20$ echo "bet" | sed -n '/b[ae]*t/p'
bet
lxc@Lxc:~/scripts/ch20$ echo "btt" | sed -n '/b[ae]*t/p'
btt
lxc@Lxc:~/scripts/ch20$ echo "baat" | sed -n '/b[ae]*t/p'
baat
lxc@Lxc:~/scripts/ch20$ echo "beet" | sed -n '/b[ae]*t/p'
beet
lxc@Lxc:~/scripts/ch20$ echo "baet" | sed -n '/b[ae]*t/p'
baet
lxc@Lxc:~/scripts/ch20$ echo "baaeaeeaeaaet" | sed -n '/b[ae]*t/p'
baaeaeeaeaaet
```

## 3. 扩展正则表达式

POSIX ERE模式提供了一些可供Linux应用程序和工具使用的额外符号。gawk支持ERE模式，但sed不支持。

> 记住，sed和gawk的正则表达式引擎之间是有区别的。gawk可以使用大多数扩展的正则表达式符号，并且提供了一些sed所不具备的额外过滤功能。但正因如此，gawk在处理数据时往往比较慢。

本节将介绍可用于gawk脚本中的常见ERE模式符号。

### 1. *问号*

问号和星号类似，但有一些不同，**问号表明前面的字符可以出现0次或1次**，仅此而已。

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk '/be?t/{print $0}'
bt
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk '/be?t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk '/be?t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "beeet" | gawk '/be?t/{print $0}'
```

跟星号一样，可以将问号和字符组一起使用。

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk '/b[ae]?t/{print $0}'
bt
lxc@Lxc:~/scripts/ch20$ echo "bat" | gawk '/b[ae]?t/{print $0}'
bat
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk '/b[ae]?t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "baet" | gawk '/b[ae]?t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "beat" | gawk '/b[ae]?t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "baat" | gawk '/b[ae]?t/{print $0}'
```

### *2. 加号*

也类似于星号，**加号表明前面的字符可以出现1次或多次，但必须至少出现一次**。

```bash
lxc@Lxc:~/scripts/ch20$ echo "beeet" | gawk '/b[ae]+t/{print $0}'
beeet
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk '/b[ae]+t/{print $0}'
beet
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk '/b[ae]+t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk '/b[ae]+t/{print $0}'
```

与星号和问号一样，也可用于字符组：

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk '/b[ae]+t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "bat" | gawk '/b[ae]+t/{print $0}'
bat
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk '/b[ae]+t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "baet" | gawk '/b[ae]+t/{print $0}'
baet
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk '/b[ae]+t/{print $0}'
beet
lxc@Lxc:~/scripts/ch20$ echo "beaaeaeaeaet" | gawk '/b[ae]+t/{print $0}'
beaaeaeaeaet
```

### *3. 花括号*

ERE中的花括号允许为正则表达式指定具体的可重复次数，这通常称为 **区间**。可以用两种格式来指定区间。

- m: 正则表达式正好出现m次
- m,n: 正则表达式至少出现m次，至多出现n次。

这个特性可以精确指定字符或字符组在模式中具体出现的次数。

> **注意：**，在默认情况下，gawk不识别正则表达式区间，必须指定gawk的命令行选项 `--re-interval` 才行。

*来几个例子：*

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk --re-interval '/be{1}t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk --re-interval '/be{1}t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk --re-interval '/be{1}t/{print $0}'
```

*指定区间下限和上限：*

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk --re-interval '/be{1,2}t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk --re-interval '/be{1,2}t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk --re-interval '/be{1,2}t/{print $0}'
beet
lxc@Lxc:~/scripts/ch20$ echo "beeet" | gawk --re-interval '/be{1,2}t/{print $0}'
```

区间也同样适用于字符组：

```bash
lxc@Lxc:~/scripts/ch20$ echo "bt" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "bat" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
bat
lxc@Lxc:~/scripts/ch20$ echo "bet" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
bet
lxc@Lxc:~/scripts/ch20$ echo "baet" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
baet
lxc@Lxc:~/scripts/ch20$ echo "baat" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
baat
lxc@Lxc:~/scripts/ch20$ echo "beet" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
beet
lxc@Lxc:~/scripts/ch20$ echo "beeet" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
lxc@Lxc:~/scripts/ch20$ echo "baaeeet" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
```

### *4. 竖线符号*

竖线符号允许在检查数据流时，以逻辑OR方式指定正则表达式引擎要使用的两个或多个模式。如果其中任何一个模式匹配了数据流文本，就视为匹配。如果没有模式匹配，则匹配失败。

*竖线符号使用格式如下：*

```bash
expr1|expr2|.....
```

*来个例子：*

```bash
lxc@Lxc:~/scripts/ch20$ echo "The cat is asleep" | gawk '/cat|dog/{print $0}'
The cat is asleep
lxc@Lxc:~/scripts/ch20$ echo "The dog is asleep" | gawk '/cat|dog/{print $0}'
The dog is asleep
lxc@Lxc:~/scripts/ch20$ echo "The sheep is asleep" | gawk '/cat|dog/{print $0}'
```

> 注意，正则表达式和竖线符号之间不能有空格，否则这个空格会被认为是正则表达式模式的一部分。

竖线符号两侧的子表达式可以采用正则表达式可用的任何模式符号。

```bash
lxc@Lxc:~/scripts/ch20$ echo "He has a cat" | gawk '/[ch]at|dog/{print $0}'
He has a cat
```

### *5. 表达式分组*

也可以用圆括号对正则表达式进行分组。分组之后，每一组会被视为一个整体，可以像对普通字符一样，对该组应用特殊字符。

```bash
lxc@Lxc:~/scripts/ch20$ echo "Sat" | gawk '/Sat(urday)?/{print $0}'
Sat
lxc@Lxc:~/scripts/ch20$ echo "Saturday" | gawk '/Sat(urday)?/{print $0}'
Saturday
```

结尾的 *urday* 分组和问号使的该模式能够匹配 *Saturday* 的全写或缩写 *Sat*。

将分组和竖线符号结合起来创建可选的模式匹配组是很常见的做法。

```bash
lxc@Lxc:~/scripts/ch20$ echo "cab" | gawk '/(c|b)a(b|t)/{print $0}'
cab
lxc@Lxc:~/scripts/ch20$ echo "cat" | gawk '/(c|b)a(b|t)/{print $0}'
cat
lxc@Lxc:~/scripts/ch20$ echo "bab" | gawk '/(c|b)a(b|t)/{print $0}'
bab
lxc@Lxc:~/scripts/ch20$ echo "bat" | gawk '/(c|b)a(b|t)/{print $0}'
bat
lxc@Lxc:~/scripts/ch20$ echo "eat" | gawk '/(c|b)a(b|t)/{print $0}'
```

## 4. 实战演练

下面演示shell脚本中一些常见的正则表达式实例。

### *1. 目录文件计数*

[countfiles.sh](./countfiles.sh)

该脚本可以对PATH环境变量中的各个目录所包含文件数量进行统计。

```bash
#!/bin/bash
# count number of files in your PATH
mypath=`echo $PATH | sed 's/:/ /g'`
total=0
count=0
for directory in $mypath
do
    check=$(ls $directory)
    for item in $check
    do
        count=$[ $count + 1 ]
        total=$[ $total + 1 ]
    done
    echo "$directory - $count"
    count=0
done

echo "Total: $total"
```

### *2. 验证电话号码*

[isphone.sh](./isphone.sh)

验证是否是一个合法的美国电话号码。

```bash
#!/bin/bash
# script to filter out bad phone numbers
gawk --re-interval '/^\(?[2-9][0-9]{2}\)?(| |-|.)[0-9]{3}( |-|\.)[0-9]{4}/{print $0}'
```

### *3. 解析email地址*

[isemail.sh](./isemail.sh)

```bash
#!/bin/bash
# script to filter out bad email address
gawk --re-interval '/^([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/{print $0}'
```