# ch17 创建函数

本章将带你逐步了解如何创建自己的shell脚本函数，并演示如何将其用于其他shell脚本。

## 1. 脚本函数基础

**函数** 是一个脚本代码块，你可以为其命名并在脚本中的任何位置重用它。每当需要在脚本中使用该代码快时，直接写函数名即可（这叫作 **调用函数**）。

### *1. 创建函数*

在bash shell脚本中创建函数的语法有两种。

- 第一种是使用关键字 `function`，随后跟上分配给该代码块的函数名：

```bash
function name {
    commands
}
```

*name* 定义了该函数的唯一名称。脚本中的函数名不能重复。*commands* 是组成函数的一个或多个bash shell命令。调用该函数时，bash shell会依次执行函数内的命令，就像在普通脚本中一样。

- 第二种在bash shell脚本中创建函数的语法更接近其他编程语言中的定义：

```bash
name () {
    commands
}
```

函数名后的空括号表明正在定义的是一个函数。这种语法的命名规则与第一种语法一样。

### *2. 使用函数*

要在脚本中使用函数，只需像其他shell命令一样写出函数名即可：

[test1.sh](./test1.sh)

```bash
#!/bin/bash
# Using a function in a script

function func1 {
    echo "This is an example of function."
}

count=1
while [ $count -le 3 ]
do
    func1
    count=$[ $count + 1 ]
done    

echo "This is the end of the loop"
func1
echo "Now this is the end of the script"
# output:
./test1.sh 
This is an example of function.
This is an example of function.
This is an example of function.
This is the end of the loop
This is an example of function.
Now this is the end of the script
```

函数不一定要放在shell脚本的最开始部分，但是要注意这种情况。如果试图在函数被定义之前使用它，则出错：

[test2.sh](./test2.sh)

```bash
#!/bin/bash
# using a function located in the middle of a script

count=1
echo "This line comes before the function definition"

function func1 {
   echo "This is an example of a function"
}

while [ $count -le 5 ]
do
   func1
   count=$[ $count + 1 ]
done
echo "This is the end of the loop"
func2
echo "Now this is the end of the script"

function func2 {
   echo "This is an example of a function"
}
# output:
bash test2.sh 
This line comes before the function definition
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is the end of the loop
test2.sh: 行 17: func2：未找到命令
Now this is the end of the script
```

另外也要注意函数名。函数名必须是唯一的，否则就会出现问题。如果定义了同名的函数，那么新定义就会覆盖函数原先的定义，而这一切不会有任何错误消息：

[test3.sh](./test3.sh)


```bash
#!/bin/bash
# Testing use a deplicate function name

function func1 {
    echo "This is the first definition of the function name"
}

func1

function func1 {
    echo "This is a repeat of the same function name"
}

func1
echo "This is the end of the script."
# output:
./test3.sh 
This is the first definition of the function name
This is a repeat of the same function name
This is the end of the script.
```

func1函数最初的定义工作正常，但重新定义该函数后，后续的函数调用会使用第二个定义。

## 2. 函数返回值

bash shell把函数视为一个小型脚本，运行结束时会返回一个退出状态码（参见第11章）。有3种方法能为函数生成退出状态码。

### *1. 默认的退出状态码*

在默认情况下，函数的退出状态码是函数中最后一个命令返回的退出状态码。函数执行结束后，可以使用标准变量`$?`来确定函数的退出状态码：

[test4.sh](./test4.sh)

```bash
#!/bin/bash
# Testing the exit statue of a function

func1() {
    echo "trying to display a non-existent file"
    ls -lF badile
}

echo "testing the function: "
func1
echo "The exit status is: $?"
# output:
 ./test4.sh 
testing the function: 
trying to display a non-existent file
ls: 无法访问 'badile': 没有那个文件或目录
The exit status is: 2
```

该函数的退出状态码非0，因为函数中最后一个命令执行失败了。同时，你也无法知道该函数中的其他命令是否执行成功。来看下面这个例子：

[test4b.sh](./test4b.sh)

```bash
#!/bin/bash
# testing the exit status of a function

func1 () {
    ls -lF badfile
    echo "This is a test of a bad command."
}

echo "testing the function:"
func1
echo "The exit status is: $?"
# output:
bash test4b.sh 
testing the function:
ls: 无法访问 'badfile': 没有那个文件或目录
This is a test of a bad command.
The exit status is: 0
```

这次，由于函数最后一个命令`echo`执行成功，因此该函数的退出状态码为0.不过其中的其他命令执行失败。使用函数的默认退出状态码是一种危险的做法。不过，有几种方法可以解决这个问题。

### *2. 使用 `return`命令*

bash shell会使用 `return` 命令以特定的退出状态码退出函数。`return` 命令允许指定一个整数值作为函数的退出状态码。

[test5.sh](./test5.sh)

```bash
#!/bin/bash
# Using the return command in a funtion

dbl() {
    read -p "Enter a value: " value
    echo "doubling the value"
    return $[ $value * 2 ]
}

dbl
echo "The new value is $?"
# output:
./test5.sh 
Enter a value: 122
doubling the value
The new value is 244
```

当使用这种方法从函数中返回值时，一定要小心。为了避免出现问题，牢记以下两个技巧。

- 函数执行一结束就立刻读取返回值
- 退出状态码必须介于0~255

如果在用 `$?` 变量提取函数返回值之前执行了其他命令，那么函数的返回值会丢失。记住：`$?`变量保存的是最后执行的那个命令的退出状态码。
第二个技巧界定了返回值的取值范围。由于退出状态码必须小于256，因此函数结果也必须为一个小于256的值。大于255的任何数值都会产生所无的值：

```bash
 ./test5.sh 
Enter a value: 200
doubling the value
The new value is 144
```

如果需要返回较大的整数值或字符串，就不能使用 `return` 方法。接下来介绍另一种方法。

### *3. 使用函数输出*

正如可以将命令的输出保存到shell变量中一样，也可以将函数的输出保存到shell变量中。

*来个例子：*

[test5b.sh](./test5b.sh)

```bash
#!/bin/bash
# Using the echo to return a value

dbl() {
    read -p "Enter a value: " value
    echo $[ $value * 2 ]
}

result=$(dbl)
echo "The new value is $result"
# output:
./test5b.sh 
Enter a value: 200
The new value is 400
```

新函数会使用 `echo` 语句来显示计算结果。该脚本会获取 *dbl* 函数的输出，而不是查看退出状态码。
这个例子演示了一个不易察觉的技巧。注意，*dbl* 函数实际上输出了两条消息。`read` 命令输出了一条简短的消息来向用户询问输入值。bash shell脚本非常聪明，并不将其作为 *STDOUT* 输出的一部分，而是直接将其忽略。如果用 `echo` 语句来生成这条消息来询问用户，那么它会与输出值一起被读入shell变量。

> 这种方法还可以返回浮点值和字符串，这使其成为一种获取函数返回值的强大方法。

## 3. 在函数中使用变量

在函数中使用变量时，需要注意它们的定义方式和处理方式。这是shell脚本中常见的错误的根源。

### *1. 向函数传递参数*

17.2节提到过，bash shell会将函数当作小型脚本来对待。这意味着你可以像普通脚本那样向函数传递参数（参见第14章）。
函数可以使用标准的位置变量来表示在命令行中传给函数的任何参数。例如，函数名保存在 `$0` 变量中，函数参数依次保存在  `$1、$2`等变量中。也可以使用特殊变量 `$#`来确定传给函数的参数数量。
在脚本中调用函数时，必须将参数和函数名放在同一行，就像下面这样：

```bash
func1 $value1 10
```

然后函数可以使用 *位置变量* 来获取参数值。

*来个例子：*

[test6.sh](./test6.sh)

```bash
#!/bin/bash
# passing parameters to a function

function addem {
   if [ $# -eq 0 ] || [ $# -gt 2 ]
   then
      echo -1
   elif [ $# -eq 1 ]
   then
      echo $[ $1 + $1 ]
   else
      echo $[ $1 + $2 ]
   fi
}

echo -n "Adding 10 and 15: "
value=$(addem 10 15)
echo $value
echo -n "Let\'s try adding just one number: "
value=$(addem 10)
echo $value
echo -n "Now trying adding no numbers: "
value=$(addem)
echo $value
echo -n "Finally, try adding three numbers: "
value=$(addem 10 15 20)
echo $value
# output:
./test6.sh 
Adding 10 and 15: 25
Let's try adding just one number: 20
Now trying adding no numbers: -1
Finally, try adding three numbers: -1
```

由于函数使用 *位置变量* 访问函数参数，因此无法直接获取脚本的命令行参数。因此下面的例子无法成功运行：

[badtest1.sh](./badtest1.sh)

```bash
#!/bin/bash
# trying to access script parameters inside a function

function badfunc1 {
   echo $[ $1 * $2 ]
}

if [ $# -eq 2 ]
then
   value=$(badfunc1)
   echo "The result is $value"
else
   echo "Usage: badtest1 a b"
fi
# output:
./badtest1.sh 
Usage: badtest1 a b
lxc@Lxc:~/scripts/ch17$ ./badtest1.sh 10 15
./badtest1.sh: 行 5: *  ：语法错误: 需要操作数 (错误符号是 "*  ")
The result is 
```

尽管函数使用了`$1`变量和`$2`变量，但它们和脚本主体中的 *\$1* 变量和 *\$2* 变量不是一回事。要在函数中使用脚本的命令行参数，必须在调用函数时手动将其传入:

[test7.sh](./test7.sh)

```bash
#!/bin/bash
# trying to access script parameters inside a function

function func7 {
   echo $[ $1 * $2 ]
}

if [ $# -eq 2 ]
then
   value=$(func7 $1 $2)
   echo "The result is $value"
else
   echo "Usage: badtest1 a b"
fi
# output:
./test7.sh 
Usage: badtest1 a b
lxc@Lxc:~/scripts/ch17$ ./test7.sh 10 13
The result is 130
```

在将 *\$1* 变量和 *\$2* 变量传给函数后，它们就能跟其他变量一样，可供函数使用了。

### 2. 在函数中处理变量

给shell脚本程序员带来麻烦情况之一就是变量的**作用域**。作用域是变量的有效区域。在函数中定义的变量与普通变量的作用域不同。也就是说，对脚本的其他部分而言，在函数中定义的变量是无效的。
函数有两种类型的变量。

- 全局变量
- 局部变量

#### *1. 全局变量*

**全局变量** 就是在shell脚本内任何地方都有效的变量。如果在脚本的主体部分定义了一个全局变量，那么就可以在函数内读取它的值。类似的，如果在函数内定义了一个全局变量，那么也可以在脚本的主体部分读取它的值。
在默认情况下，在脚本中定义的任何变量都是全局变量。在函数外定义的变量可以在函数内正常访问。

[test8.sh](./test8.sh)

```bash
#!/bin/bash
# using a global variable to pass a value

dbl() {
    value=$[ $value * 2 ]
}

read -p "Enter a value: " value
dbl
echo "The new value is $value"
# output:
./test8.sh 
Enter a value: 12
The new value is 24
```

有时我们会在函数内不经意修改全局变量的值，这可能导致我们意外的结果：

[badtest2.sh](./badtest2.sh)

```bash
#!/bin/bash
# demonstrating a bad use of variables

function func1 {
   temp=$[ $value + 5 ]
   result=$[ $temp * 2 ]
}

temp=4
value=6

func1
echo "The result is $result"
if [ $temp -gt $value ]
then
   echo "temp is larger"
else
   echo "temp is smaller"
fi
# output:
./badtest2.sh 
The result is 22
temp is larger
```

所以，我们可以使用局部变量。

#### *2. 局部变量*

无须在函数内使用全局变量，任何在函数内使用的变量都可以被声明为局部变量。为此，只需在变量声明之前加上关键字 `local` 即可：

```bash
local variable
```

也可以在变量赋值语句中使用 `local` 关键字:

```bash
local temp=$[ $value + 5 ]
```

`local` 关键字保证了变量仅在该函数中有效。如果函数之外有同名变量，那么shell会保持这两个变量的值互不干扰。这意味着你可以轻松地将函数变量和脚本变量分离开，只共享需要共享的变量：

[test9.sh](./test9.sh)

```bash
#!/bin/bash
# demonstrating the local keyword

function func1 {
   local temp=$[ $value + 5 ]
   result=$[ $temp * 2 ]
}

temp=4
value=6

func1
echo "The result is $result"
if [ $temp -gt $value ]
then
   echo "temp is larger"
else
   echo "temp is smaller"
fi
# output:
./test9.sh 
The result is 22
temp is smaller
```

现在，当你在 *func1* 函数中使用 *\$temp* 变量时，该变量的值不会影响到脚本主体中赋给 *\$temp*的值

## 4. 数组变量和函数

第5章讨论过使用数组在单个变量中保存多个值的高级用法。在函数中使用数组变量有点儿麻烦，需要做一些特殊考虑。

### *1. 向函数传递数组*

向脚本函数传递数组变量的方法有点难以理解。将数组变量当作单个参数传递的话，它不会起作用：

[badtest3.sh](./badtest3.sh)

```bash
#!/bin/bash
# trying to pass an array variable

function testit {
   echo "The parameters are: $@"
   thisarray=$1
   echo "The received array is ${thisarray[*]}"
}
 
myarray=(1 2 3 4 5)
echo "The original array is: ${myarray[*]}"
testit $myarray
# output:
./badtest3.sh 
The original array is: 1 2 3 4 5
The parameters are: 1
The received array is 1
```

如果试图将数组作为函数参数进行传递，则函数智慧提取数组变量的第一个元素。
要解决这个问题，必须先将数组变量拆解成多个数组元素，然后将这些数组元素作为函数参数传递。最后在函数内部，将所有的参数重新组合成一个新的数组变量。来看下面的例子：

[test10.sh](./test10.sh)

```bash
#!/bin/bash
# array variable to function test

function testit {
   local newarray
   newarray=(`echo "$@"`)
   echo "The new array value is: ${newarray[*]}"
}

myarray=(1 2 3 4 5)
echo "The original array is ${myarray[*]}"
testit ${myarray[*]}
# output:
./test10.sh 
The original array is 1 2 3 4 5
The new array value is: 1 2 3 4 5
```

在函数内部，数组可以照常使用：

[test11.sh](./test11.sh)

```bash
#!/bin/bash
# adding values in an array

function addarray {
    local sum=0
    local newarray
    newarray=(`echo "$@"`)
    for value in ${newarray[*]}
    do
        sum=$[ $sum + $value ]
    done    
    echo $sum
}

myarray=(1 2 3 4 5)
echo "The original array is ${myarray[*]}"
result=$(addarray ${myarray[*]})
echo "The result is $result"
# output:
./test10.sh 
The original array is 1 2 3 4 5
The new array value is: 1 2 3 4 5
```

### *2. 从函数返回数组*

[test12.sh](./test12.sh)

```bash
#!/bin/bash
# returing an array value

function arrayblr {
    local origarray
    local newarray
    local elements
    local i
    origarray=($(echo "$@"))
    newarray=(`echo "$@"`)
    elements=$[ $# - 1 ]
    for(( i = 0; i <= elements; i++ ))
    {
        newarray[$i]=$[ ${origarray[$i]} * 2 ]
    }
    echo ${newarray[*]}
}

myarray=(1 2 3 4 5)
echo "The orignal array is ${myarray[*]}"
arg1=$(echo ${myarray[*]})
result=($(arrayblr $arg1))
echo "The new array is ${result[*]}"
# output:
./test12.sh 
The orignal array is 1 2 3 4 5
The new array is 2 4 6 8 10
```

## 5. 函数递归

局部变量的函数的一个特性是**自成体系（self-containment）**。除了获取函数参数外，自成体系的函数不需要任何外部资源。这个特性使得函数可以递归地调用。

*来个例子：*


[test13.sh](./test13.sh)

```bash
#!/bin/bash
# using recursion

function factorial {
    if [ $1 -eq 1 ]
    then
        echo 1
    else
        local temp=$[ $1 - 1 ]
        local result=$(factorial $temp)
        echo $[ $result * $1 ]
    fi
}

read -p "Enetr value: " value
result=$(factorial $value)
echo "The factorial of $value is $result."
# output:
./test13.sh 
Enetr value: 10
The factorial of 10 is 3628800.
```

## 6. 创建库

bash shell允许创建 **库文件**，允许多个脚本文件引用此库文件。

1. 创建库文件的第一步就是创建一个包含所需函数的共用库文件。
来看一个库文件 *myfuncs*，其中定义了3个简单函数：

2. 第二步就是在需要用到这些函数的脚本文件中包含 *myfuncs* 库文件。这里有点小问题：
问题出在shell的作用域上。和环境变量一样，shell函数仅在定义它的shell会话内有效。如果在shell命令行界面运行 *myfuncs* 脚本，那么shell会创建一个新的shell并在其中运行这个脚本。在这种情况下，以上3个函数会定义在新shell中，当你运行另一个要用到这些函数的脚本时，它们是无法使用的。

[badtest4.sh](./badtest4.sh)

```bash
#!/bin/bash
# using a library file the wrong way
./myfuncs

result=$(addem 10 15)
echo "The result is $result."
# output:
./badtest4.sh 
./badtest4.sh: 行 5: addem：未找到命令
The result is .
```

使用函数库的关键在于 `source` 命令。`source` 命令会在当前shell的上下文中执行命令，而不是创建新shell并在其中执行命令。可以用 `source`命令在脚本中运行库文件，这样脚本就可以使用库中的函数了。
`source` 命令有个别名，称作**点号操作符**。要在shell脚本中运行 *myfuncs* 库文件，只需添加下面这一行代码：

```bash
. ./myfuncs
```

这个例子假定 *myfuncs* 库文件和shell脚本文件位于同一目录(*实际上*，你运行 *test14.sh* 这个脚本时，必须在ch17这个目录下，否则还是同样找不到，这个相对路径是相对于命令执行时的路径的，并不是相对于脚本文件的路径)。如果不是，则需要使用正确路径访问该文件。

[test14.sh](./test14.sh)

```bash
#!/bin/bash
# using functions defined in a library file
. ./myfuncs

value1=10
value2=5
result1=$(addem $value1 $value2)
result2=$(multem $value1 $value2)
result3=$(divem $value1 $value2)
echo "The result of adding them is: $result1"
echo "The result of multiplying them is: $result2"
echo "The result of dividing them is: $result3"
# output:
./test14.sh 
The result of adding them is: 15
The result of multiplying them is: 50
The result of dividing them is: 2
```

## 7. 在命令行中使用函数

### *1. 在命令行中创建函数*

因为shell会解释用户输入的命令，所以可以在命令行中直接定义一个函数。有两种方法。

1. 一种方法是采用单行的方式来定义函数

```bash
lxc@Lxc:~/scripts$ function divem { echo $[ $1 / $2 ]; }
lxc@Lxc:~/scripts$ divem 100 5
20
```

当你在命令行中定义函数时，必须在每个命令后面加个分号，这样shell就能知道哪里是命令的起止了：

```bash
lxc@Lxc:~/scripts$ function doubleit { read -p "Enter value: " value; echo $[ $value * 2 ]; }
lxc@Lxc:~/scripts$ doubleit 
Enter value: 10
20
```

2. 另一种方法是采用多行方式来定义函数。在定义时，bash shell会采用次提示符来提示输入更多命令。
使用这种方法，无须在每条命令的末尾放置分号，只需按下回车键即可：

```bash
lxc@Lxc:~/scripts$ function multem {
> echo $[ $1 * $2 ]
> }
lxc@Lxc:~/scripts$ multem 2 5
10
```

输入函数尾部的花括号后，shell就知道你已经完成函数的定义了。

> **警告：** 在命令行创建函数时要特别小心。如果给函数起了一个跟内建命令或另一个命令相同的名字，那么函数就会覆盖原来的命令。

### 2. 在 .bashrc 文件中定义函数

在命令行中定义函数的一个明显缺点是，在退出shell时，函数也会消失。我们可以将函数定义在每次新shell启动时都会重新读取该函数的地方。而 *.bashrc* 文件就是这个最佳位置。不管是交互式shell还是从现有shell启动新的shell，bash shell在每次启动时都会在用户主目录中查找这个文件。

#### *1. 直接定义函数*

只需将你要定义的函数放在 *.bashrc* 文件的末尾即可。该函数会在下次启动新的bash shell时生效，或者你在当前已经启动的shell中执行一遍 ```source ~/.bashrc```也行。

```bash
# 一些自定义函数
function addem {
    echo $[ $1 + $2 ]
}
# 该函数来自 ~/.bashrc文件
# 以下来自命令行终端
lxc@Lxc:~/scripts/ch17$ addem 1 2 
3
```

#### *2. 源引函数文件*

只要是在shell脚本文件中，就可以用 `source` 命令（或其别名，即点号操作符）将库文件中的函数添加到 *.bashrc* 文件中。同样下次启动新的设立了时生效，或者你在当前已经启动的shell中执行一边 ```source ~/.bashrc```也行。

**更棒的是**，shell还会将定义好的函数传给子shell进程，这样一来，这些函数就能够自动用于该shell会话中的任何shell脚本了。你可以写个脚本，试试在不定义或不源引函数的情况下直接使用函数会是什么结果：

[test15.sh](./test15.sh)

```bash
#!/bin/bash
# using a function defined in the .bashrc file

value1=10
value2=5
result1=$(addem $value1 $value2)
result2=$(multem $value1 $value2)
result3=$(divem $value1 $value2)
echo "The result of adding them is: $result1"
echo "The result of multiplying them is: $result2"
echo "The result of dividing them is: $result3"
# 按照书上所说，输出应该是:
./test15.sh
The result of adding them is: 15
The result of multiplying them is: 50
The result of dividing them is: 2
# 但是当我实践时，只有以source命令执行test15.sh这个脚本时这个脚本才能找到函数的定义，用其他命令均出错（找不到函数定义）：
lxc@Lxc:~/scripts/ch17$ ./test15.sh 
./test15.sh: 行 8: addem：未找到命令
./test15.sh: 行 9: multem：未找到命令
./test15.sh: 行 10: divem：未找到命令
The result of adding them is: 
The result of multiplying them is: 
The result of dividing them is: 
lxc@Lxc:~/scripts/ch17$ bash test15.sh 
test15.sh: 行 8: addem：未找到命令
test15.sh: 行 9: multem：未找到命令
test15.sh: 行 10: divem：未找到命令
The result of adding them is: 
The result of multiplying them is: 
The result of dividing them is: 
lxc@Lxc:~/scripts/ch17$ source test15.sh 
The result of adding them is: 15
The result of multiplying them is: 50
The result of dividing them is: 2
# 只有在使用 source 命令时未出错
```
参考[ch16 README.md](../ch16/README.md)末尾对 `source`命令和 `bash` 命令的区别。
按照书上所说，``shell 还会将定义好的函数传给子shell进程``，那么即使是用 `bash` 命令执行脚本不应该不出错吗？？？？为啥出错呢。。。。
