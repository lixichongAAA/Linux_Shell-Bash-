# ch13 更多的结构化命令

## 13.1 *for* 命令

*命令格式*：

```bash
for var in list
do
    commands
done
```

也可以将`do`语句和`for`语句放在一行，使用分号隔开：
```bash
for var in list; do
    commands
done
```
> 之后的循环语句也是同理，循环语句和后面的`do`语句之间均可放在同一行，使用分号隔开。

### ***1. 读取列表中的值***

在最后一次迭代结束后，*$var* 变量中的值在shell脚本的剩余部分依然有效。它会一直保持最后一次迭代时的值（除非做了修改）

*例如*：

[test1b.sh](./test1b.sh)
```bash
#!/bin/bash
# Testing the for variable after the looping

for test in AlaBama Alaska Arizona Arkansas California Colorado
do
    echo "The next state is $test"
done
echo "The last state we visited was $test"
test=Connecticut
echo "Wait, now we're visiting $test"
```

### ***2. 读取列表中的复杂值***

shell看到 *list* 中的单引号会尝试使用他们来定义一个单独的数据值，这会导致一些问题，
我们有两种方法解决:

- 使用转义字符将单引号转义
- 使用双引号来定义含有单引号的值

*例如*：
[test2.sh](./test2.sh)
```bash
#!/bin/bash
# another example of how not to use the for command

for test in I don\'t know if "this'll" work; do
    echo "word:$test"
done
# 在第一个有问题的地方使用反斜线进行了转义，第二个有问题的地方，将this'll放在了双引号内，
# 这两种方法都管用.
```

*for* 循环假定 *list* 中各个值是以空格（制表符、换行符）分隔的，如果某个值含有空格，
则必须将其放入双引号内：

[test3.sh](./test3.sh)
```bash
 #!/bin/bash
 # an example of how to properly define values
for test in Nevada "New Hampshire" "New Mexico" "New York"
do
   echo "Now going to $test"
done
```
### ***3. 从变量中读取列表值***

[test4.sh](./test4.sh)
```bash
#!/bin/bash
# using a variable to hold the list
 
list="Alabama Alaska Arizona Arkansas Colorado"
list=$list" Connecticut" # 这里是字符串拼接
 
for state in "$list"
do
   echo "Have you ever visited $state?"
done
```
### ***4. 从命令中读取值列表***

生成值列表的另一种途径是使用命令的输出。
你可以使用 ***命令替换*** 来生成值列表
（注： 命令替换： $() 或者 ``）

*例如*：
[test5.sh](./test5.sh)
```bash
#!/bin/bash
# reading values from a file    

file="states.txt"
for state in $(cat $file)
do
    echo "Visit beautiful $state"
done

```

### ***5. 更改字段分隔符***

前文有讲，bash shell默认使用(空格、制表符、换行符)作为字段分隔符。
可以通过修改 `IFS` 环境变量的值来修改字段分隔符。
*例如*

```bash
IFS=$'\n' # 字段分隔符仅为换行符
IFS=: # 字段分隔符仅为冒号，用于遍历文件中以冒号分隔的值(比如/etc/passwd)
IFS=$'\n:;"' # 也可以指定多个IFS字符。该语句将换行符、冒号、分号和双引号作为字段分隔符
```
有时候，我们需要**在一个地方修改IFS的值，然后再将其复原**可以使用下面的手法：

```bash
IFS.old=$IFS
IFS=$'\n' #更改为新的IFS值
<在代码中使用新的IFS值>
IFS=$IFS.old
```

### ***6. 使用通配符读取目录***

可以使用 *for* 命令来遍历目录中的文件。为此，必须使用在文件名或者路径名中使用通配符，
这会强制shell使用 **文件名通配符匹配**。

*例如*:

[test6.sh](./test6.sh)
```bash
#!/bin/bash
# iterate through all the files in a directory

for file in /home/lxc/scripts/* /home/lxc/Go/* # 可以列出多个目录通配符.
do
    if [ -d "$file" ]
    then
        echo "$file is a directory."
    elif [ -f "$file" ] 
    then
        echo "$file is a file."
    fi
done
```
> 因为在Linux中，文件名或者目录名中包含空格是完全合法的，要应对这种情况，应该将 `$file` 变量放在双引号内。

## 2. C语言风格的 *for* 命令

*命令格式*：

```bash
for (( variable assignment; condition; iteration process ))
```

该命令格式和bash shell标准的`for`命令并不一致
- 变量赋值可以有空格
- 迭代条件中的变量不以美元符号开头
- 迭代过程的算式不使用`expr`命令格式

*例如*：

[test9.sh](./test9.sh)

```bash
#!/bin/bash
# multiple variables

for (( a=1, b=10; a <= 10; a++, b-- ))
do
    echo "$a - $b"
done
```

## 3. *while* 命令

只有在命令产生的退出状态码为0时，`while`循环才会继续迭代。

### ***1. while的基本格式***

```bash
while test command
do
    other commands
done
```

当然，如之前所言

```bash
while test command; do
    other commands
done
```
这样的形式也可以。

`test command` (即 *条件测试* 命令)最常见的用法是使用方括号:

[test10.sh](./test10.sh)

```bash
#!/bin/bash
# while command test

var1=10
while [ $var1 -gt 0 ]
do
    echo $var1
    var1=$[ $var1 - 1 ]
done
```

### ***2. 使用多个测试命令***

> 注意: `while`命令允许在 `while` 语句行定义多个测试命令。**只有最后一个测试命令的退出状态码会被用于决定是否结束循环**。

[test11.sh](./test11.sh)
```bash
#!/bin/bash
# testing a multicommand while loop
 
var1=3

while echo $var1 
      [ $var1 -ge 0 ]
do
   echo "This is inside the loop"
   var1=$[ $var1 - 1 ]
done
# output
# 3
# This is inside the loop
# 2
# This is inside the loop
# 1
# This is inside the loop
# 0
# This is inside the loop
# -1 注意额外多输出的这个 -1
```
> 注意： 在指定多个测试命令时，注意要把每个测试命令单独放在一行中(除了 [ ] &&/|| [ ] 这种情况)；否则出错。

## 4. *until* 命令

`until`命令和`while`命令的工作方式正相反。只要测试命令的退出状态码不为0，bash shell就会执行循环中的命令。直至测试命令返回了状态码0，循环结束。

*命令格式*：

```bash
until test commnand
do 
    other commands
done
```

- 如前所述，`do`也可以与`until`放在同一行，中间用分号隔开。
- 与`while`命令类似，你可以在`until`命令语句中放入多个`test command`。最后一个命令的退出状态码决定了bash shell是否执行已定义的`other commands`。

> 注意： 在指定多个测试命令时，注意要把每个测试命令单独放在一行中(除了 [ ] &&/|| [ ] 这种情况)；否则出错。（与`while`一样）。

## 5. 嵌套循环

循环语句可以在循环内使用任意类型的命令，包括其他循环命令，这称为 **嵌套循环**。
举两个例子吧：

[test14.sh](./test14.sh)

```bash
#!/bin/bash
# nesting for loops

for (( a = 1; a <= 3; a++ ))
do
    echo "Starting loop $a:"
    for (( b = 1; b <= 3; b++ ))
    do
        echo "      Inside loop: $b"
    done
done
```

[test15.sh](./test15.sh)
[test16.sh](./test16.sh)

```bash
# !/bin/bash
# using until and while loops

var1=3

until [ $var1 -eq 0 ]
do
    echo "Outer loop: $var1"
    var2=1
    while [ $var2 -lt 5 ]
    do
        var3=$(echo "scale=4; $var1 / $var2" | bc)
        echo "Inner loop: $var1 / $var2 = $var3"
        var2=$[ $var2 + 1 ]
    done
    var1=$[ $var1 - 1 ]
done
```

## 6. 循环处理文件数据

*例如：*

[test16_.sh](./test16_.sh)
```bash
#!/bin/bash
# changing the IFS value

IFS.old=$IFS
IFS=$'\n'
for entry in $(cat /etc/passwd)
do
    echo "Values in $entry -"
    IFS=:
    for value in $entry
    do
        echo "  $value"
    done
done
```

## 7. 循环控制

### ***1. break命令***

你可以使用`break`命令退出任意类型的循环。

#### ***1. 跳出单个循环***

*例如：*

[test17.sh](./test17.sh)
[test18.sh](./test18.sh)

```bash
#!/bin/bash
# breaking out of a for loop

for var1 in 1 2 3 4 5 6 7 8 9 10
do
    if [ $var1 -eq 5 ]
    then
        break
    fi
    echo "Iteration number: $var1"
done
echo "The for loop is completed."
```

#### ***2. 跳出内层循环***

*例如：*

[test19.sh](./test19.sh)

```bash
#!/bin/bash
# breaking out of an inner loop

for (( a = 1; a <= 3; a++ ))
do
    echo "Outer loop: $a"
    for(( b = 1; b <= 100; b++ ))
    do
        if [ $b -eq 5 ]
        then
            break
        fi
        echo "  Inner loop: $b"
    done
done
echo "done."
```

#### ***3. 跳出外层循环***

**有时你位于内层循环，但需结束外层循环。`break`命令接受单个命令行参数：**

```bash
break n
```

其中`n`指定了要跳出的循环层级，默认情况下，`n`为1，表明跳出的是当前循环。如果将`n`设为2，则`break`命令会停止下一层级的外层循环：
[test20.sh](./test20.sh)

```bash
#!/bin/bash
# breaking out of an outer loop

for (( a = 1; a <= 3; a++ ))
do
    echo "Outer loop: $a"
    for((b = 1; b <= 100; b++ ))
    do
        if [ $b -eq 5 ]
        then
            break 2
        fi
        echo "  Inner loop: $b"
    done
done
echo "done."
```

### ***2. continue命令***

跳过某次循环，但不终止循环。

[test21.sh](./test21.sh)

```bash
#!/bin/bash
# using the continue command.

for (( var1 = 1; var1 <= 20; var1++ ))
do
    if [ $var1 -gt 5 ] && [ $var1 -lt 10 ]
    then
        continue
    fi
    echo "Iteration number: $var1"
done
echo "Done."
```

**与`break`命令一样，`continue`命令也允许通过命令行参数指定要继续执行哪一级的循环：**

```bash
continue n
```

下面是一个继续执行外层`for`循环的例子：

[test22.sh](./test22.sh)

```bash
#!/bin/bash
# continuing an outer loop

for ((a = 1; a <= 8; a++)); do
    echo "Outer loop: $a"
    for ((b = 1; b <= 3; b++)); do
        if [ $a -gt 3 ] && [ $a -lt 6 ]; then
            continue 2
        fi
        var3=$(($a * $b))
        echo "  The result of $a * $b is $var3."
    done
done
echo "Done."
```

## 8. 处理循环的输出

在shell脚本中，**可以对循环的输出使用管道或进行重定向。这可以通过在`done`命令之后添加一个处理命令来实现**

下面这个例子将`for`命令的输出重定向至文件：

[test23.sh](./test23.sh)

```bash
#!/bin/bash
# redirecting the for output to a file

for (( a = 1; a <= 5; a++ ))
do
    echo "Iteration number: $a"
done > output.txt
echo "Done."
```

下面这个例子使用了输入重定向:

[test26.sh](./test26.sh)

```bash
#!/bin/bash
# process new user accounts

input="users.csv"

while IFS=',' read -r userid name; do
    echo "adding $userid"
    useradd -c "$name" -m $userid
done <"$input"

```

下面这个例子使用管道：

[test24.sh](./test24.sh)

```bash
#!/bin/bash
# piping a loop to another command

for state in "North Dakota" Connecticut Illinois AlaBama Tenessee
do
    echo "$state is the next place to go."
done | sort
echo "Done."
```
`for`命令的输出通过管道传给了`sort`命令，由后者对输出结果进行排序。

