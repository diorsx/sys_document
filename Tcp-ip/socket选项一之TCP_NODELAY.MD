# socket选项

------

### 一、选项介绍
在Linux网络编程中，有时需要设置地址复用，允许发送广播包，将主机加入某个多播组，设置发送与接收缓冲区的大小，设置发送与接收的超时时间，将套接字绑定到某个接口上,发送TCP探测包查看客户端是否保持连接等，这些都需要对套接字选项进行设置.而对套接字选项进行操作的主要有以下两个函数,
setsockopt与getsockopt.这两个函数不仅能够操作套接字层，而且能够操作IP层与TCP层。

###### 1、函数原型
int getsockopt(int sock, int level, int optname, void *optval, socklen_t *optlen);

int setsockopt(int sock, int level, int optname, const void *optval, socklen_t optlen);

> * sock：将要被设置或者获取选项的套接字;
> * level：选项所在的协议层;
> * optname：需要访问的选项名;
> * optval：对于getsockopt()，指向返回选项值的缓冲;
    对于setsockopt()，指向包含新选项值的缓冲;
> * optlen：对于getsockopt()，作为入口参数时，选项值的最大长度。作为出口参数时，选项值的实际长度;
    对于setsockopt()，现选项的长度;

###### 2、参数详细说明

level指定控制套接字的层次.可以取三种值:
1)SOL_SOCKET:通用套接字选项;
2)IPPROTO_IP:IP选项;
3)IPPROTO_TCP:TCP选项;　

optname指定控制的方式(选项的名称)

optval获得或者是设置套接字选项.根据选项名称的数据类型进行转换　

------

### 二、TCP_NODELAY选项

Nagle算法通过将未确认的数据存入缓冲区直到蓄足一个包一起发送的方法，来减少主机发送的零碎小数据包的数目。但对于某些应用来说，这种算法将降低系统性能。
所以TCP_NODELAY可用来将此算法关闭。应用程序编写者只有在确切了解它的效果并确实需要的情况下，才设置TCP_NODELAY选项，因为设置后对网络性能有明显的负面影响。
TCP_NODELAY是唯一使用IPPROTO_TCP层的选项，其他所有选项都使用SOL_SOCKET层。

** TCP_NODELAY选项禁止Nagle算法 **

------

### 三、测试及效果验证

```python
#!/bin/env python
# -*- coding:utf-8 -*-
import select
import socket
import time
import sys

s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
print "IPPROTO_TCP: %s" %socket.IPPROTO_TCP
print "TCP_NODELAY: %s" %socket.TCP_NODELAY

s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
try:
    s.connect(('www.baidu.com', 80))
except Exception as e:
    print "error %s" %e
    sys.exit(1)

for i in "hello":
    s.send(i)

s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 0)
s.send('w')
s.send('o')
s.send('r')
s.send('l')
s.send('d')

time.sleep(5)
```

![抓包截图](https://raw.githubusercontent.com/diorsx/HubPhotos/master/tcp_nodely_01.png)

> * 1、TCP三次握手过程
> * 2、启用TCP_NODELAY，发包过程
> * 3、禁用TCP_NODELAY，发包过程


