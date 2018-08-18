# Redis持久化方式

------

Redis是一个基于内存的高性能key-value数据库，由于数据存储在内存里，当系统或redis服务发生异常，导致服务退出时，将要丢失这部分数据；
所以Reids提供下述持久化的方式：
1、内存快照(snapshots)
2、追加文件(append-only file)

------
## 一、内存快照(snapshots)

缺省情况情况下，Redis把数据快照存放在磁盘上的二进制文件中，文件名为dump.rdb；
可以配置快照的持久化策略，例如数据集中每N秒钟有超过M次更新，就将数据写入磁盘，或者手工调用命令SAVE或BGSAVE；
当触发SAVA命令时，SAVE命令会阻塞Redis服务器进程，直到RDB文件创建完毕为止，在服务器进程阻塞期间，服务器不能处理任何命令请求；
当触发BGSAVE命令时，BGSAVE命令会派生出一个子进程，然后由子进程负责创建RDB 文件，服务器进程(父进程)继续处理命令请求。

自动触发RDB机制的场景有：
1) 使用save相关配置，如‘save m n’表示m秒之内数据集存在n次修改时，自动触发bgsave；
2）如果从节点执行全量复制操作，主节点自动执行bgsave生成RDB文件并发送给从节点；
3）执行debug reload命令重新加载Redis时，也会自动触发save操作；
4）默认情况下执行shutdown命令时，如果没有开启AOF持久化功能则自动执行bgsave。

缺点：
1：若服务崩溃，会丢失save时间点至崩溃点的数据；
2：在数据集较大、CPU性能不够强悍时fork()调用可能很耗时从而会导致Redis在几毫秒甚至一秒中的时间内不能服务clients；

------

# 二、追加文件(append-only file)

以独立日志的方式记录每次写命令，重启时再重新执行AOF文件中命令达到恢复数据的目的；
AOF的主要作用是解决了数据持久化的实时性，快照模式并不十分健壮，当系统停止，或者无意中Redis被kill掉，最后写入Redis的数据就会丢失。
打开追加文件的选项为：appendonly yes

工作流程操作：命令写入（append）、文件同步（sync）、文件重写（rewrite）、重启加载（load）

基本配置：
appendonly 是否开启AOF持久化
appendfilename AOF文件名称
appendfsync 刷新数据到磁盘的频率

当有写入命令，修改redis数据集时，有下述三种文件同步方式：
appendfsync always  每次写入都要同步AOF文件，会严重影响Redis性能；
appendfsync no 由操作系统保证buf中的数据写入磁盘；
appendfsync erveysec 每秒同步buf数据到磁盘中，兼顾性能和数据安全性，理论上只有在系统突然宕机的情况下丢失1s的数据。

AOF重写机制：
由于命令不断写入AOF，文件会越来越大，为了解决这个问题，Redis引入了AOF重写机制压缩文件体积；
AOF文件重写是把Redis进程内的数据转化为写命令同步到新AOF文件的过程；

AOF重写过程可以手动触发和自动触发
手动触发：直接调用bgrewriteaof命令
自动触发：由auto-aof-rewrite-min-size和auto-aof-rewrite-percentage参数确定自动触发时机
auto-aof-rewrite-min-size    表示运行AOF重写时文件最小体积，默认为64MB
auto-aof-rewrite-percentage  表示当前AOF文件空间（aof_current_size）和上一次重写后AOF文件空间（aof_base_size）的值

