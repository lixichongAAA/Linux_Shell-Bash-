# ch16 脚本控制

到目前为止，运行脚本的唯一方式就是有需要时直接在命令行启动。当然这并不是唯一的方式，还有很多方式可以用来运行shell脚本。你也可以对脚本加以控制，包括向脚本发送信号、修改脚本的优先级，以及切换脚本的运行模式。本章将逐一介绍这些控制方法。

## 1. 处理信号

Linux利用信号与系统中的进程进行通信。第4章介绍过不同的Linux信号以及Linux如何用这些信号来停止、启动以及杀死进程。你可以对脚本进行编程，使其在收到特定信号时执行某些命令，从而控制shell脚本的操作。

### *1. 重温Linux信号*

Linux系统和应用程序可以产生超过30个信号。下表列出在shell脚本编程时会遇到的最常见的Linux系统信号。

|信号|值|描述|
| :-: | :---: | :------: |
|1|SIGHUP|挂起（hang up）进程|
|2|SIGINT|中断（interrupt）进程|
|3|SIGQUIT|停止进程（stop）|
|9|SIGKILL|无条件终止（terminate）进程|
|15|SIGTERM|尽可能终止进程|
|18|SIGCONT|继续（continue）运行停止的进程|
|19|SIGSTOP|无条件停止，但不终止进程|
|20|SIGTSTP|停止或暂停（pause），但不终止进程|

在默认情况下bash shell会忽略收到的任何 *SIGQUIT(3)* 和 *SIGTERM(15)* 信号（因此交互式shell才不会被意外终止）。但是bash shell会处理收到的所有 *SIGHUP(1)* 和 *SIGINT(2)* 信号。
如果受到了 *SIGHUP* 信号（比如在离开交互式shell时），bash shell就会退出。但在退出之前，它会将 *SIGHUP* 信号传给所有由该shell启动的进程，包括正在运行的shell脚本。
随着受到 *SIGINT* 信号，shell会被中断。Linux内核将不再为shell分配CPU处理时间。当出现这种情况时，shell会将 *SIGINT* 信号传给由其启动的所有进程，以此告知出现的状况。
你可能也注意到了，shell会将这些信号传给shell脚本来处理。而shell脚本的默认行为是忽略这些信号，因为可能不利于脚本运行。要避免这种情况，可以在脚本中加入识别信号的代码，并做相应的处理。

### *2. 产生信号*

bash shell允许键盘上的两种组合键来生成两种基本的Linux信号。这个特性在需要停止或暂停失控脚本时非常方便。

#### *1. 中断进程*

Ctrl+C组合键会生成 *SIGINT* 信号，并将其发送给当前在shell中运行的所有进程。

```bash
$ sleep 60
^C
$
```

在超时前（60秒）按下Ctrl+C组合键，就可以提前终止`sleep`命令

#### *2. 暂停进程*

Ctrl+Z组合键可以生成 *SIGTSTP* 信号，停止shell中运行的任何进程。停止（stopping）进程跟终止（terminating）进程不同，前者让程序继续驻留在内存中，还能从上次停止的位置继续运行。16.4节将介绍如何重启一个已经停止的进程。
当使用Ctrl+Z组合键时，shell会通知你进程已经被停止了：

```bash
$ sleep 60
^Z
[1]+  已停止               sleep 60
```
方括号中分配的数字是 **作业号**。shell将运行的各个进程称为 **作业**，并为作业在当前shell内分配了唯一的作业号。作业号从1开始，然后是2，以此递增。
如果shell会话中有一个已停止的作业，那么在退出shell时，bash会发出提醒：

```bash
$ sleep 70
^Z
[2]+  已停止               sleep 70
$ exit
exit
有停止的任务。
```

可以用 `ps` 命令来查看已停止的作业：

```bash
$ ps -l
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 S  1000    5616    5599  0  80   0 -  4495 do_wai pts/1    00:00:00 bash
0 T  1000    6751    5616  0  80   0 -  2791 do_sig pts/1    00:00:00 sleep
0 T  1000    6849    5616  0  80   0 -  2791 do_sig pts/1    00:00:00 sleep
4 R  1000    6994    5616  0  80   0 -  3628 -      pts/1    00:00:00 ps
```

在S列（进程状态）中，`ps`命令将已停止作业的状态显示为T。这说明命令要么被跟踪，要么被停止。
如果在有已停止作业的情况下仍旧想退出，则只需要再输入一边`exit`命令即可。shell会退出，终止已停止作业。或者，如果知道已停止作业的PID，那就可以用kill命令发送 *SIGKILL（9）*信号将其终止：

```bash
$ kill -9 6751
[1]-  已杀死               sleep 60
$ kill -9 6849
[2]+  已杀死               sleep 70
```

每当shell生成命令行提示符时，也会显示shell中状态发生改变的作业。杀死作业后，shell会显示一条消息，表示运行中的作业已被杀死，然后生成提示符

> **注意:** 在某些Linux系统中，杀死作业时并不会得到任何回应，但当下次执行能让shell生成命令行提示符的操作时（比如，按下Enter键），你会看到一条消息，表示作业已被杀死。

### *3. 捕获信号*

你也可以用其他命令在信号出现时将其捕获，而不是忽略信号。**`tarp`** 命令可以指定shell脚本需要侦测并拦截的Linux信号。如果脚本收到了`trap`命令中列出的信号，则该信号不再由shell处理，而是由本地处理。

*命令格式：*

```bash
trap commands signals
```

在`tarp`命令中，需要在 *commands* 部分列出想要shell执行的命令，在 *signals* 部分列出想要捕获的信号（多个信号之间以空格分隔）。指定信号的时候，可以使用信号的值或者信号名。

*来个例子：*

[trapsignal.sh](./trapsignal.sh)

```bash
#!/bin/bash
# Testing signal trapping
# 
trap "echo ' Sorry! I have trapped Ctrl-C'" SIGINT
# 
echo This is a test script.
# 
count=1
while [ $count -le 5 ]
do  
    echo "Loop #$count."
    sleep 1
    count=$[ $count + 1 ]
done
# 
echo This is the end of the script.
exit
# output:
 ./trapsignal.sh 
This is a test script.
Loop #1.
^C Sorry! I have trapped Ctrl-C
Loop #2.
^C Sorry! I have trapped Ctrl-C
Loop #3.
^C Sorry! I have trapped Ctrl-C
Loop #4.
^C Sorry! I have trapped Ctrl-C
Loop #5.
This is the end of the script.
# 每次使用Ctrl+C组合键，脚本都会执行trap命令中指定的echo语句，而不是忽略信号并让shell停止该脚本。
```

### *4. 捕获脚本退出*

除了在shell脚本中捕获信号，也可以在shell脚本退出时捕获信号。这是在shell完成任务是执行命令的一种简便方法。
要捕获shell脚本的退出，只需在`trap`命令后加上`EXIT信号即可`：

[trapexit.sh](./trapexit.sh)

```bash
#!/bin/bash
# Testing exit trapping
# 
trap "echo GoodBye..." EXIT
# 
count=1
while [ $count -le 5 ]
do
    echo "Loop #$count"
    sleep 1
    count=$[ $count + 1 ]
done
# 
exit
# output:
./trapexit.sh 
Loop #1
Loop #2
Loop #3
Loop #4
Loop #5
GoodBye...
# 当脚本运行到正常的退出位置时，触发了EXIT，shell执行了在trap命令中指定的命令。
# 如果提前退出脚本，则依然能捕获到EXIT：
./trapexit.sh 
Loop #1
Loop #2
^CGoodBye...
# 因为SIGINT信号并未在trap命令的信号列表中，所以当按下Ctrl+C组合键发送SIGINT信号时，脚本就退出了。但在退出之前已经触发了EXIT，于是shell会执行trap命令。
```

### *5. 修改或移除信号捕获*

要想在脚本的不同位置进行不同的信号捕获，只需重新使用带有新选项的`trap`命令即可：

[trapmod.sh](./trapmod.sh)

```bash
#!/bin/bash
# Modifying a set trap
# 
trap "echo ' Sorry...Ctrl-C is trapped.'" SIGINT
# 
count=1
while [ $count -le 3 ]
do
    echo "Loop #$count"
    sleep 1
    count=$[ $count + 1 ]
done
# 
trap "echo ' I have modified the trap!'" SIGINT
# 
count=1
while [ $count -le 3 ]
do
    echo "Loop #$count"
    sleep 1
    count=$[ $count + 1 ]
done
# 
exit
# output:
./trapmod.sh 
Loop #1
^C Sorry...Ctrl-C is trapped.
Loop #2
Loop #3
Loop #1
^C I have modified the trap!
Loop #2
Loop #3
# 如你所见，在前三次和后三次捕获信号所执行命令产生的消息是不同的。
```

> **提示：**如果在交互式shell会话中使用trap命令，可以使用 trap -p 查看被捕获的信号。如果什么都没有显示，则说明shell会话按照默认方式处理信号。

也可以移除已设置好的信号捕获。在`trap`命令与希望恢复默认行为的信号列表之间加上两个连字符即可。

[trapremoval.sh](./trapremoval.sh)

```bash
#!/bin/bash
# Removing a set trap
# 
trap "echo ' Sorry...Ctrl-C is trapped.'" SIGINT
# 
count=1
while [ $count -le 3 ]
do
    echo "Loop #$count"
    sleep 1
    count=$[ $count + 1 ]
done
# 
trap -- SIGINT
echo "The trap is now removed."
# 
count=1
while [ $count -le 3 ]
do
    echo "Loop #$count"
    sleep 1
    count=$[ $count + 1 ]
done
# 
exit
# output：
./trapremoval.sh 
Loop #1
^C Sorry...Ctrl-C is trapped.
Loop #2
Loop #3
The trap is now removed.
Loop #1
^C
# 如你所见，在移除信号捕获后，使用Ctrl+C提前终止了脚本的执行。
```
移除信号捕获后，脚本会按照默认行为处理 *SIGINT* 信号，也就是终止脚本运行。
> 也可以在`trap`命令后使用单连字符来恢复信号的默认行为。单连字符和双连字符的效果一样。

## 2. 以后台模式运行脚本

在后台模式中，进程运行时不和终端会话的 *STDOUT*、*STDIN* 以及 *STDERR*关联。

### *1. 后台模式运行脚本*

以后台模式运行shell脚本非常简单，只需在脚本名后面加上`&`即可：

[backgroundscript.sh](./backgroundscript.sh)

```bash
#!/bin/bash
#Test running in the background
#
count=1
while [ $count -le 5 ]
do
     sleep 1
     count=$[ $count + 1 ]
done
#
exit
# output:
./backgroundscript.sh &
[1] 5073
$ 
# 在脚本名之后加上&会将脚本与当前shell分离开来，并将脚本作为一个独立的后台进程运行。
```
方括号中的数字1是shell分配给后台进程的作业号，之后的数字（5073）是Linux系统为进程分配的进程ID（PID）。Linux系统中的每个进程都必须有唯一PID。
一旦显示了这些内容，就会出现新的命令行界面提示符。返回到当前shell，刚才执行的脚本则会以后台模式安全地退出。这时，就可以继续在命令行中输入新的命令了。
当后台进程结束时，终端上会显示一条消息：

```bash
$ 
[1]+  已完成               ./backgroundscript.sh
```

其中，指明了作业号、作业状态（Done），以及用于启动该作业的命令（删除了`&`）。

> 注意，当后台进程运行时，它仍然会使用终端显示器来显示 *STDOUT* 和 *STDERR* 消息。

[backgroundoutput.sh](./backgroundoutput.sh)

```bash
#!/bin/bash
#Test running in the background
#
echo "Starting the script..."
count=1
while [ $count -le 5 ]
do
     echo "Loop #$count"
     sleep 1
     count=$[ $count + 1 ]
done
#
echo "Script is completed."
exit
# output:
./backgroundoutput.sh &
[1] 5833
Starting the script...
Loop #1
$ # 这里是按了一下Enter键
$ # 这里是按了一下Enter键
Loop #2
Loop #3
Loop #4
Loop #5
Script is completed.

[1]+  已完成               ./backgroundoutput.sh
# 你会注意到脚本的输出与shell提示符混在了一起，
# 这个时候你如果执行其他命令，则命令的输出也会和脚本的输出混在一起
# 最好是将后台脚本的STDOUT和STDERR进行重定向，避免这种杂乱的输出。
```

### *2. 运行多个后台作业*

在使用命令行提示符的情况下，可以同时启动多个作业：

```bash
./testAscript.sh &
[1] 6946
This is Test Script #1.
$ ./testBscript.sh &
[2] 6953
This is Test Script #2.
$ ./testCscript.sh &
[3] 6957
$ And... another Test script.

$ ./testDscript.sh &
[4] 6961
$ Then...there was one more Test script.
$ ps
    PID TTY          TIME CMD
   5588 pts/1    00:00:00 bash
   6747 pts/1    00:00:00 sleep
   6946 pts/1    00:00:00 testAscript.sh
   6948 pts/1    00:00:00 sleep
   6953 pts/1    00:00:00 testBscript.sh
   6955 pts/1    00:00:00 sleep
   6957 pts/1    00:00:00 testCscript.sh
   6959 pts/1    00:00:00 sleep
   6961 pts/1    00:00:00 testDscript.sh
   6963 pts/1    00:00:00 sleep
   6982 pts/1    00:00:00 ps
# 通过ps命令了那个可以看到，所有脚本都处于运行状态
```

> 注意：在`ps`命令的输出中，每一个后台进程都和终端会话（pts/1）终端关联在一起。如果终端会话退出，那么后台进程也会随之退出
> 注意，本章先前提到过，当要退出终端会话时，如果还有被停止的进程，就会出现警告信息。
但如果是后台进程，则只有部分终端仿真器会在退出终端绘画前提醒你尚有后台进程在运行。

如果在登出控制台后，仍希望运行在后台模式的脚本继续运行，则需要借助其他手段。下一节讨论实现方法。

## 3. 在非控制台下运行脚本

有时候，即便退出了终端会话，你也想在终端会话中启动shell脚本，让脚本一直以后台模式运行结束。这可以用  **`nohup`** 命令来实现。

`nohup`命令能够阻断发给特定进程的`SIGHUP`信号。当退出终端会话时，可以避免进程退出。

*命令格式：*

```bash
nohup command
```

*来个例子：*

```bash
 nohup ./testAscript.sh &
[1] 7511
nohup: 忽略输入并把输出追加到'nohup.out'

# 退出终端后，再进行查询：
ps -elf | grep testA
0 S lxc         7511    2189  0  80   0 -  3145 do_wai 11:28 ?        00:00:00 /bin/bash ./testAscript.sh
0 R lxc         7907    7640  0  80   0 -  3001 -      11:29 pts/1    00:00:00 grep --color=auto testA
# 发现testAscript.sh脚本并未退出
```

和普通后台进程一样，shell会给 *command* 分配一个作业号，Linux系统会为其分配一个PID号。区别在于，当使用`nohup`命令时，如果关闭终端会话，则脚本会忽略其发送的 *SIGHUP* 信号。
由于`nohup`命令会解除终端与进程之间的关联，因此进程不再同 *STDOUT* 和 *STDERR* 绑定在一起。为了保存该命令产生的输出，`nohup`命令会自动将 *STDOUT* 和 *STDERR* 产生的消息重定向到一个名为 *nohup.out* 的文件中。

> 注意， *nohup.out* 文件一般在当前目录创建，否则会在 *$HOME* 目录创建。

```bash
cat nohup.out 
This is Test Script #1.
```

> 注意，如果使用`nohup`命令运行了另一命令，那么该命令的输出会被追加到已有的 *nohup.out* 文件中。
当运行同一目录中的多个命令时，要注意，因为所有的命令输出都会发送到同一个 *nohup.out* 文件中，结果会让人摸不到头脑

借助`nohup`命令，可以在无须停止脚本进程的情况下，登出终端会话去完成其他任务，随后可以检查结果。下一节将介绍更为灵活的后台作业管理方法。

## 4. 作业控制

**作业控制** 包括启动、停止、杀死、以及恢复作业。通过作业控制，你能完全控制shell环境中所有进程的运行方式。

### *1. 查看作业*

**`jobs`** 命令允许用户查看的当前正在处理的作业。

[jobcontrol.sh](./jobcontrol.sh)

```bash
./jobcontrol.sh 
Script process id: 8162
Loop #1.
^Z
[1]+  已停止               ./jobcontrol.sh
$ ./jobcontrol.sh > jobcontrol.out &
[2] 8302
$ jobs
[1]+  已停止               ./jobcontrol.sh
[2]-  运行中               ./jobcontrol.sh > jobcontrol.out &
$ jobs -l 
[1]+  8162 停止                  ./jobcontrol.sh
[2]-  8302 运行中               ./jobcontrol.sh > jobcontrol.out &
$ kill -9 8162
[1]+  已杀死               ./jobcontrol.sh
```

> **注意：** 关于`jobs`命令输出中的加号与减号。带有加号的作业为 **默认作业**。
如果作业控制命令没有指定作业号，则引用的就是该默认作业。
带有减号的作业会在默认作业结束后成为下一个默认作业。
任何时候，不管shell运行着多少作业，带加号的作业只能有一个，带减号的作业也只能有一个。


`jobs`命令提供了一些命令行选项，如下表：

|选项|描述|
| :--: | :-----------: |
|-l|列出进程的PID以及作业号|
|-n|只列出上次shell发出通知后状态发生改变的作业|
|-p|只列出进程的PID|
|-r|只列出运行中的作业|
|-s|只列出已停止的作业|

### *2. 重启已停止的作业*

在bash作业控制中，可以将已停止的作业作为后台进程或前台进程重启。前台进程会接管当前使用的终端，因此在使用该特性时要小心。
要以后台模式重启作业，可以使用 **`bg`** 命令：

```bash
./restartjob.sh 
^Z
[1]+  已停止               ./restartjob.sh
$ bg
[1]+ ./restartjob.sh &
$ jobs -l
[1]+  6014 运行中               ./restartjob.sh &
# 因为该作业是默认作业（从加号可以看出），所以仅使用bg命令就可以将其以后台模式重启。
```

如果存在多个作业，则需要在`bg`命令后加上作业号，以便于控制。
要以前台模式重启作业，可以使用带有作业号的 **`fg`** 命令：

```bash
$ jobs
[1]-  已停止               ./restartjob.sh
[2]+  已停止               ./newrestartjob.sh
$ fg 2
./newrestartjob.sh
This is the script's end.
```
因为作业是前台运行的，因此直到该作业完成后，命令行界面的提示符才会出现。

## 5. 调整谦让度

在多任务操作系统比如（Linux）中，内核负责为每个运行的进程分配CPU时间。**调度优先级**（也称为**谦让度**（nice value））是指内核为进程分配的CPU时间（相对于其他进程）。在Linux系统中，由shell启动的所有进程的调度优先级默认都是相同的。
调度优先级是一个整数值，**取值范围为-20（最高优先级）到+19（最低优先级）**。在默认情况下，bash shell以优先级0来启动所有进程。

> -20（最低值）代表最高优先级，+19代表最低优先级，这很容易记住。只要记住那句俗话 "Nice guys finish last"即可，越是谦让（值越大）获得的CPU的机会就越低。

### *1.`nice`命令*

`nice`命令允许在启动命令时设置其调度优先级。要想让命令以*更低* 的优先级运行，只需用`nice`命令的`-n`选项指定优先级即可

```bash
nice -n 10 ./jobcontrol.sh > jobcontrol.out &
[1] 6935
ps -p 6935 -o pid,ppid,ni,cmd
    PID    PPID  NI CMD
   6935    5329  10 /bin/bash ./jobcontrol.sh
```

`nice`命令使得脚本以更低的优先级运行，它会阻止普通用户提高命令的优先级。只有root用户或者特权用户才能提高命令的优先级。
`nice`命令的 `-n` 选项不是必须的，直接在连字符后面跟上优先级也可以：

```bash
nice -10 ./jobcontrol.sh > jobcontrol.out &
[1] 7628
$ ps -p 7628 -o pid,ppid,ni,cmd
    PID    PPID  NI CMD
   7628    7338  10 /bin/bash ./jobcontrol.sh
```
当然，当要设置的优先级是负数时，这种写法很容易造成混淆，因为出现了双连字符。在这种情况下，最好还是使用`-n`选项。

### *2. `renice` 命令*

有时候，你想修改系统中已运行命令的优先级。`renice`命令可以帮你搞定。它通过指定运行进程的PID来改变其优先级：

```bash
./jobcontrol.sh > jobcontrol.out &
[1]+  已完成               nice -10 ./jobcontrol.sh > jobcontrol.out
[1] 7798
$ ps -p 7798 -o pid,ppid,ni,cmd
    PID    PPID  NI CMD
   7798    7338   0 /bin/bash ./jobcontrol.sh
$ renice -p 7798 -n 10
renice: invalid priority '-p'
Try 'renice --help' for more information.
$ renice -n 10 -p 7798
7798 (process ID) 旧优先级为 0，新优先级为 10
$ ps -p 7798 -o pid,ppid,ni,cmd
    PID    PPID  NI CMD
   7798    7338  10 /bin/bash ./jobcontrol.sh
```

`renice` 命令会自动更新运行进程的调度优先级。和`nice`命令一样，`renice`命令对于非特权用户也有一些限制：只能对属主自己的进程使用`renice`且只能降低调度优先级。但是root用户和特权用户可以使用`renice`命令对任意进程的优先级做任意调整。

## 6. 定时运行脚本

Linux系统提供了多个在预选时间运行脚本的方法：`at`命令、`cron`表以及`anacron`。

### 1. 使用`at`命令调度作业

`at`命令允许指定Linux系统何时运行脚本。该命令会将作业提交到队列中，指定shell何时运行该作业。
`at`的守护进程`atd`在后台运行，在作业列表中检查待运行的作业。
`atd`守护进程会检查系统的一个特殊目录(通常位于 */var/spool/at* 或 */var/spool/cron/atjobs*)，从中获取`at`命令提交的作业。在默认情况下，`atd`守护进程每隔60秒检查一次这个目录。如果其中有作业，那么`atd`守护进程就会查看此作业的运行时间。如果时间跟当前时间一致，就运行此作业。

#### *1. `at`命令的格式*

*命令格式：*

```bash
at [-f filename] time
```

`-f`选项指定用于从中读取命令（脚本文件）的文件名。`time`选项指定你希望何时运行该作业。指定时间的方式非常灵活。`at`命令能识别多种时间格式。

- 标准的小时和分钟，比如 10:15
- AM/PM指示符，比如 10:15 PM
- 特定的时间名称，比如 now、noon、midnight、teatime(4：00 p.m.)
除了指定运行作业的时间，也可以通过不同的日期格式指定特定的日期。
- 标准日期，比如 MMDDYY、MM/DD/YY、DD.MM.YY 
- 文本日期，比如 Jul 4、Dec 25，加不加年份均可。
- 时间增量

    - Now+25 minutes
    - 10:15 PM tomorrow
    - 10:15 + 7 days

> `at`命令可用的日期和时间格式有很多种，具体参见 */usr/share/doc/at/timespec* 文件

在使用`at`命令时，该作业会被提交至**作业队列**。作业队列保存着通过`at`命令提交的待处理作业。针对不同的优先级，有52种作业队列。作业队列通常用小写字母a~z和大写字母A~Z来指代，A队列和a队列是两个不同的队列。

> 在几年前，`batch`命令也能指定脚本的执行时间。这是个很独特的命令，因为它可以安排脚本在系统处于低负载时运行。现在`batch`命令只不过是一个脚本而已(*/usr/bin/batch*)，它会调用`at`命令将作业提交到b队列中。

作业队列的字幕排序越高，此队列中的作业运行优先级就越低（谦让度越大）。在默认情况下，`at`命令提交的作业会被放入a队列。如果想以较低的优先级运行作业，可以使用 `-q`选项指定其他的队列。如果相较于其他进程你希望你的作业尽可能少的占用CPU，可以将其放入到z队列。

#### *2. 获取作业的输出*

当在Linux系统中运行`at`命令时，显示器并不会关联到该作业。Linux系统反而会将提交该作业的用户email地址作为 *STDOUT* 的 *STDERR*。任何送往*STDOUT* 和 *STDERR*的输出都会通过邮件系统传给该用户。

*来个例子：*

[tryat.sh](./tryat.sh)

```bash
#!/bin/bash
# Trying out the at command
# 
echo "This script ran at $(date +%B%d,%T)"
echo
echo "This script is using the $SHELL shell."
echo
sleep 5
echo "This is the script's end."
# 
exit
# output:
$ at -f tryat.sh now
warning: commands will be executed using /bin/sh
job 8 at Wed Nov  8 20:50:00 2023
```

无需在意`at`命令输出的告警信息，因为脚本的第一行是 #!/bin/bash，该命令有bash shell执行。
使用email作为`at`命令的输出极不方便。`at`命令通过`sendmail`应用程序发送email。如果系统中没有安装sendmail，那就无法获得任何输出。因此在使用`at`命令时，最好在脚本中对 *STDOUT* 和 *STDERR*进行重定向。

[tryatout.sh](./tryatout.sh)

```bash
#!/bin/bash
# Trying out the at command redirecting output
#
outfile=$HOME/scripts/ch16/tryat.out
#
echo "This script ran at $(date +%B%d,%T)" > $outfile
echo >> $outfile
echo "This script is using the $SHELL shell." >> $outfile
echo >> $outfile
sleep 5
echo "This is the script's end." >> $outfile
#
exit
# output:
$ at -M -f tryatout.sh now # -M 选项用于禁止给用户发送邮件
warning: commands will be executed using /bin/sh
job 9 at Wed Nov  8 20:57:00 2023
$ cat tryat.out 
This script ran at 十一月08,20:57:27

This script is using the  shell.

This is the script's end.
```

#### *3. 列出等待的作业*

**`atq`** 命令可以查看系统中有哪些作业在等待：

```bash
at -M -f tryatout.sh teatime
warning: commands will be executed using /bin/sh
job 10 at Thu Nov  9 16:00:00 2023
lxc@Lxc:~/scripts/ch16$ at -M -f tryatout.sh tomorrow
warning: commands will be executed using /bin/sh
job 11 at Thu Nov  9 21:01:00 2023
lxc@Lxc:~/scripts/ch16$ at -M -f tryatout.sh 21:30
warning: commands will be executed using /bin/sh
job 12 at Wed Nov  8 21:30:00 2023
lxc@Lxc:~/scripts/ch16$ at -M -f tryatout.sh now+1hour
warning: commands will be executed using /bin/sh
job 13 at Wed Nov  8 22:01:00 2023
lxc@Lxc:~/scripts/ch16$ atq
12      Wed Nov  8 21:30:00 2023 a lxc
13      Wed Nov  8 22:01:00 2023 a lxc
11      Thu Nov  9 21:01:00 2023 a lxc
10      Thu Nov  9 16:00:00 2023 a lxc
# 作业列表中显示了作业号、系统运行该作业的日期和时间，以及该作业所在的作业队列。
```

#### *4. 删除作业*

一旦知道了哪些作业正在作业队列中等待，就可以用 **`atrm`** 命令删除等待中的作业。指定要删除的作业号即可：

```bash
lxc@Lxc:~/scripts/ch16$ atq
12      Wed Nov  8 21:30:00 2023 a lxc
13      Wed Nov  8 22:01:00 2023 a lxc
11      Thu Nov  9 21:01:00 2023 a lxc
10      Thu Nov  9 16:00:00 2023 a lxc
lxc@Lxc:~/scripts/ch16$ atrm 10
lxc@Lxc:~/scripts/ch16$ atq
12      Wed Nov  8 21:30:00 2023 a lxc
13      Wed Nov  8 22:01:00 2023 a lxc
11      Thu Nov  9 21:01:00 2023 a lxc
lxc@Lxc:~/scripts/ch16$ atrm 11 12 13
lxc@Lxc:~/scripts/ch16$ atq
```
只能删除自己提交的作业，不能删除其他人的。

### 2. 调度需要定期运行的脚本

Linux系统使用 **`cron`** 程序调度需要定期执行的作业。**`cron`**在后台运行，并会检查一个特殊的表(**cron时间表**)，从中获知已安排执行的作业。

#### *1. `cron时间表`*

`cron`时间表通过一种特别的格式指定作业何时运行，其格式如下：

```bash
minutepasthour hourofday dayofmonth month dayofweek command
```

`cron`时间表允许使用特定值、取值范围（比如1～5）或者通配符（星号）来指定各个字段。

*来几个例子：*

如果想在每天的10:15分运行一个命令，可以使用如下的时间表字段：

```bash
15 10 * * * command
```

每周一的下午4:15分执行命令，可以使用军事时间(24小时制):

```bash
15 16 * * 1 command
```

可以使用三字符的文本值(mon、tue、wed、thu、fri、sat、sun)或数值（0或7代表周日6代表周六）来指定 *dayofweek* 字段。

每个月的第一天的中午12点执行命令：

```bash
00 12 1 * * command
```

*dayofmonth* 字段指定的是月份中的日期值(1 ~ 31)。

> 提示：如何设置命令在每个月的最后一天执行，因为无法设置一个 *dayofmonth* 值，涵盖所有月份的最后一天。
> - 常用的解决方法是加一个 `if-then`语句，在其中使用`date`命令来检查明天的日期是不是某个月份的第一天(01)：
00 12 28-31 * * if [ "$(date +%d -d tomorrow)" = 01 ] ; then command; fi
这行脚本会在每天中午12点检查当天是不是当月的最后一天（28～31），如果是，就由 `cron`执行 *command* 
> - 另一种方法是将 *command* 替换成一个控制脚本（controlling script），在可能是每月最后一天的时候运行。控制脚本包含 `if-then` 语句，用于检查第二天是否为某个月的第一天。如果是，则由控制脚本发出命令，执行必须在当月最后一天执行的内容。

命令列表必须指定要运行的命令或者脚本的完整路径。你可以像在命令行中那样，添加所需的任何选项和重定向符：

```bash
15 10 * * * /home/lxc/scripts/ch16/backup.sh > backup.out
```

`cron`程序会以提交作业的用户身份运行该脚本，因此你必须有访问该脚本、命令以及输出文件的权限。

#### *2. 构建 `cron`时间表*

每个用户都可以使用自己的`cron`时间表运行已安排好的任务。Linux提供了 **`crontab`** 命令来处理 `cron时间表`。要列出自己的`cron`时间表，可以用`-l`选项：

```bash
lxc@Lxc:~/scripts/ch16$ crontab -l
no crontab for lxc
```

在默认情况下，用户的`cron`时间表文件并不存在。可以使用`-e`选项向`cron`时间表添加字段。在添加字段时，`crontab`命令会启动一个文本编辑器（参见第十章），使用已有的`cron`时间表作为文件内容（如果时间表不存在，就是一个空文件）。

#### *3. 浏览 `cron`目录*

如果创建的脚本对于执行时间的精确性要求不高，则用预配置的 `cron` 脚本目录会更方便。预配置的基础目录共有4个： *hourly、daily、monthly、weekly*。

```bash
lxc@Lxc:~/scripts/ch16$ ls /etc/cron.*ly
/etc/cron.daily:
0anacron  apport  apt-compat  aptitude  bsdmainutils  cracklib-runtime  dpkg  google-chrome  logrotate  man-db  mlocate  popularity-contest  sysstat  update-notifier-common

/etc/cron.hourly:

/etc/cron.monthly:
0anacron

/etc/cron.weekly:
0anacron  apt-xapian-index  man-db  update-notifier-common
```

如果你的脚本每天运行一次，那么将脚本复制到 *daily* 目录， `cron` 就会每天运行它。

#### *4. `anacron`程序*

`cron`程序唯一的问题是它假定Linux系统是7*24小时运行的。除非你的Linux系统运行在服务器环境，否则这种假设未必成立。
如果某个作业在`cron`时间表中设置的时间已到，但这时候Linux系统处于关闭状态，那么该作业就不会运行。当再次启动系统时，`cron`程序不会再去运行那些错过的作业。为了解决这个问题，许多Linux发行版提供了 **`anacron`** 程序。
如果`anacron`程序判断出某个作业错过了设置的运行时间，它会尽快运行该作业。这意味着如果Linux系统关闭了几天，等到再次启动时，原计划在关机期间运行的作业会自动运行。有了`anacron`，就能确保作业一定能运行，这正是通常使用`anacron`代替`cron`调度作业的原因。
`anacron`程序只处理位于`cron`目录的程序，比如 */etc/cron.monthly*。它通过时间戳来判断作业是否在正确的时间间隔内运行了。每个`cron`目录都有一个时间戳文件，该文件位于 */var/spool/anacron:* 

```bash
lxc@Lxc:~/scripts/ch16$ ls -lF /var/spool/anacron/
总用量 12
-rw------- 1 root root 9 11月  8 16:46 cron.daily
-rw------- 1 root root 9 10月 29 13:11 cron.monthly
-rw------- 1 root root 9 11月  8 16:51 cron.weekly
lxc@Lxc:~/scripts/ch16$ sudo cat /var/spool/anacron/cron.daily 
[sudo] lxc 的密码： 
20231108
```

`anacron`程序使用自己的时间表（通常位于 */etc/anacrontab*）来检查作业目录：

```bash
lxc@Lxc:~/scripts/ch16$ cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root
LOGNAME=root

# These replace cron's entries
1       5       cron.daily      run-parts --report /etc/cron.daily
7       10      cron.weekly     run-parts --report /etc/cron.weekly
@monthly        15      cron.monthly    run-parts --report /etc/cron.monthly
```

`anacron`时间表的基本格式和`cron`时间表略有不同：

```bash
period delay identifier command
```

*period* 字段定义了作业的运行频率（以天为单位）。`anacron`程序使用该字段检查作业的时间戳文件。*delay*字段指定了在系统启动后，`anacron`程序需要等待多少分钟再开始运行错过的脚本。

> 注意：`anacron`不会运行位于 */etc/cron.hourly*目录的脚本。这是因为`anacron`并不处理执行时间需求少于一天的脚本。*identifier* 字段是一个独特的非空字符串，比如 *cron.weekly*。它唯一的作用是标识出现在日志消息和email中的作业。*command* 字段包含了 `run-parts`程序和一个`cron`脚本目录名。`run-parts`程序负责运行指定目录中的所有脚本。

## 7. 使用新Shell启动脚本

如果每次用户启动新的bash shell时都能运行相关的脚本，那将会非常方便，因为有时候你希望为shell会话设置某些shell特性，或者希望已经设置了某个文件。
这时可以回想一下当用户登录bash shell时要运行的启动文件（参见第6章）。另外别忘了，不是所有的发行版都包含这些启动文件。基本上，以下所列文件中的第一个文件会被运行，其余的则被忽略。

- $HOME/.bash_profile
- $HOME/.bash_login
- $HOME/.profile

因此，应该将需要在 登陆时 运行的脚本放在上述的第一个文件中。
每次启动新shell，bash shell都会运行.bashrc文件。对此进行验证，可以使用这种方法：在主目录下的.bashrc文件中加入一条简单的`echo`语句，然后启动一个新shell。

.bashrc文件通常也借由某个bash启动文件来运行，因为.bashrc文件会运行两次：一次是当用户登录bash shell时，另一次是当用户启动bash shell时，如果需要某个脚本在两个时刻都运行，则可以将其放入该文件。

## 8. 实战演练

[trapandrun.sh](./trapandrun.sh)

```bash
#!/bin/bash
# Set specified signal traps; then run script in background
#
####################### Check Signals to Trap #######################
#
while getopts S: opt   #Signals to trap listed with -S option
do
     case "$opt" in 
          S) # Found the -S option
             signalList="" #Set signalList to null
             #
             for arg in $OPTARG
             do
                  case $arg in
                  1)   #SIGHUP signal is handled
                       signalList=$signalList"SIGHUP "
                  ;;
                  2)   #SIGINT signal is handled
                       signalList=$signalList"SIGINT "
                  ;;
                  20)  #SIGTSTP signal is handled
                       signalList=$signalList"SIGTSTP "
                  ;;
                  *)   #Unknown or unhandled signal
                       echo "Only signals 1 2 and/or 20 are allowed."
                       echo "Exiting script..."
                       exit
                  ;;
                  esac
             done
             ;;
          *) echo 'Usage: -S "Signal(s)" script-to-run-name'
             echo 'Exiting script...'
             exit
             ;;
     esac
     #
done
#
####################### Check Script to Run #######################
#
shift $[ $OPTIND - 1 ] #Script name should be in parameter
#
if [ -z $@ ]
then
     echo
     echo 'Error: Script name not provided.'
     echo 'Usage: -S "Signal(s)"  script-to-run-name'
     echo 'Exiting script...'
     exit 
elif [ -O $@ ] && [ -x $@ ]
then
     scriptToRun=$@
     scriptOutput="$@.out"
else
     echo 
     echo "Error: $@ is either not owned by you or not excecutable."
     echo "Exiting..."
     exit
fi 
#
######################### Trap and Run ###########################
#
echo
echo "Running the $scriptToRun script in background"
echo "while trapping signal(s): $signalList"
echo "Output of script sent to: $scriptOutput"
echo
trap "" $signalList  #Ignore these signals
#
source $scriptToRun > $scriptOutput &  #Run script in background
#
trap -- $signalList  #Set to default behavior
#
####################### Exit script #######################
#
exit
```
```bash
lxc@Lxc:~/scripts/ch16$ ./trapandrun.sh -S "1 2 20" testTandR.sh

Running the testTandR.sh script in background
while trapping signal(s): SIGHUP SIGINT SIGTSTP 
Output of script sent to: testTandR.sh.out

lxc@Lxc:~/scripts/ch16$ ps
    PID TTY          TIME CMD
   4178 pts/1    00:00:00 bash
   6224 pts/1    00:00:00 trapandrun.sh
   6225 pts/1    00:00:00 sleep
   6231 pts/1    00:00:00 ps
lxc@Lxc:~/scripts/ch16$ kill -1 6224
lxc@Lxc:~/scripts/ch16$ cat testTandR.sh.out 
This is a test script.
Loop #1
Loop #2
lxc@Lxc:~/scripts/ch16$ kill -2 6224
lxc@Lxc:~/scripts/ch16$ cat testTandR.sh.out 
This is a test script.
Loop #1
Loop #2
Loop #3
lxc@Lxc:~/scripts/ch16$ kill -20 6224
lxc@Lxc:~/scripts/ch16$ ps
    PID TTY          TIME CMD
   4178 pts/1    00:00:00 bash
   6224 pts/1    00:00:00 trapandrun.sh
   6376 pts/1    00:00:00 sleep
   6395 pts/1    00:00:00 ps
lxc@Lxc:~/scripts/ch16$ cat testTandR.sh.out 
This is a test script.
Loop #1
Loop #2
Loop #3
Loop #4
lxc@Lxc:~/scripts/ch16$ cat testTandR.sh.out 
This is a test script.
Loop #1
Loop #2
Loop #3
Loop #4
Loop #5
lxc@Lxc:~/scripts/ch16$ cat testTandR.sh.out 
This is a test script.
Loop #1
Loop #2
Loop #3
Loop #4
Loop #5
This is the end of test script.
lxc@Lxc:~/scripts/ch16$ ps
    PID TTY          TIME CMD
   4178 pts/1    00:00:00 bash
   6495 pts/1    00:00:00 ps
lxc@Lxc:~/scripts/ch16$ 
```

在阅读该控制脚本时，有一个地方需要注意：检查文件是否有执行权限并不是必需的。当使用`source`命令运行脚本时，就像bash一样，无须在文件中设置执行权限。这种方式与使用`bash`运行脚本差不多，只是不会创建子shell。