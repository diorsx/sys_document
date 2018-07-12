# RabbitMQ简介

------

## 一、概述

### 1.1 什么是MQ

MQ全称为Message Queue, 消息队列（MQ）是一种应用程序对应用程序的通信方法。
应用程序通过读写出入队列的消息（针对应用程序的数据）来通信，而无需专用连接来链接它们。消息传递指的是程序之间通过在消息中发送数据进行通信，而不是通过直接调用彼此来通信，直接调用通常是用于诸如远程过程调用的技术。排队指的是应用程序通过 队列来通信。队列的使用除去了接收和发送应用程序同时执行的要求。

MQ特点
MQ是消费-生产者模型的一个典型的代表，一端往消息队列中不断写入消息，而另一端则可以读取或者订阅队列中的消息。MQ和JMS类似，但不同的是JMS是SUN JAVA消息中间件服务的一个标准和API定义，而MQ则是遵循了AMQP协议的具体实现和产品。

使用场景
在项目中，将一些 **无需即时返回且耗时的操作提取出来，进行异步处理** ，而这种异步处理的方式大大的节省了服务器的请求响应时间，从而提高了系统的吞吐量。

### 1.2 什么是AMQP

AMQP，即Advanced Message Queuing Protocol,一个提供统一消息服务的应用层标准高级消息队列协议,是应用层协议的一个开放标准,为面向消息的中间件设计。基于此协议的客户端与消息中间件可传递消息，并不受客户端/中间件不同产品，不同的开发语言等条件的限制。Erlang中的实现有 RabbitMQ等。

### 1.3 什么是RabbitMQ

RabbitMQ是一个开源的AMQP实现，服务器端用Erlang语言编写，支持多种客户端，如：Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP等，支持AJAX。用于在分布式系统中存储转发消息，在易用性、扩展性、高可用性等方面表现不俗。
**用于组件的解耦**

------

## 二、RABBITMQ内部对象

### 2.1 交换机(Exchange)

交换机作用是接收消息，转发消息到队列，其有四种类型，分别为Direct, Fanout , Topic and Headers；
Direct：直连交换机是一种带路由功能的交换机，一个队列会和一个交换机绑定，除此之外再绑定一个routing_key，当消息被发送的时候，需要指定一个binding_key，这个消息被送达交换机的时候，就会被这个交换机送到指定的队列里面去；
Fanout：扇形交换机会把能接收到的消息全部发送给绑定在自己身上的队列；
Topic：类似直连交换机，但其binding_key带有正则表达式
headers：首部交换机是忽略routing_key的一种路由方式。路由器和交换机路由的规则是通过Headers信息来交换的，这个有点像HTTP的Headers。

交换机属性：
> *持久性：如果启用，交换器将会在server重启前都有效；
> *自动删除：如果启用，那么交换器将会在其绑定的队列都被删除掉之后自动删除掉自身；
> *惰性：如果没有声明交换器，那么在执行到使用的时候会导致异常，并不会主动声明；

```python
#申明交换机
import pika

username = 'test'
passwd = 'passwd'
SERVER_IP = '10.10.10.10'
SERVER_PORT = 5672
SERVER_VHOST = 'vhost_data'

credentials = pika.PlainCredentials(username, passwd)
connection = pika.BlockingConnection(pika.ConnectionParameters(SERVER_IP, SERVER_PORT, SERVER_VHOST, credentials))
channel = connection.channel()

# 声明交换机
exchange_name = 'test_ex'
try:
    channel.exchange_declare(exchange_name, 'fanout', durable=True)
except:
    print "It has declare exchange"
```
------

### 2.2 队列(Queue)

Queue（队列）是RabbitMQ的内部对象，用于存储消息, RabbitMQ中的消息都只能存储在Queue中,多个消费者可以订阅同一个Queue，这时Queue中的消息会被平均分摊给多个消费者进行处理，而不是每个消费者都收到所有的消息并处理。

队列的属性：
> *持久性：如果启用，队列将会在server重启前都有效。
> *自动删除：如果启用，那么队列将会在所有的消费者停止使用之后自动删除掉自身。
> *惰性：如果没有声明队列，那么在执行到使用的时候会导致异常，并不会主动声明。
> *排他性：如果启用，队列只能被声明它的消费者使用。

```python
#申明队列
import pika

username = 'test'
passwd = 'passwd'
SERVER_IP = '10.10.10.10'
SERVER_PORT = 5672
SERVER_VHOST = 'vhost_data'
exchange_name = 'test_ex'

credentials = pika.PlainCredentials(username, passwd)
connection = pika.BlockingConnection(pika.ConnectionParameters(SERVER_IP, SERVER_PORT, SERVER_VHOST, credentials))
channel = connection.channel()

#声明队列，并绑定到交换机上
queue_name = 'test_q'
try:
    result =channel.queue_declare(durable=True, auto_delete=False, exclusive=False, queue=queue_name)
except Exception as e:
    print e.message

try:
    channel.queue_bind(exchange=exchange_name, queue=queue_name)
except Exception as e:
    print e.message
```
------

### 2.3 消息传递

消息在队列中保存，以轮询的方式将消息发送给监听消息队列的消费者，可以动态的增加消费者以提高消息的处理能力。为了实现负载均衡，可以在消费者端通知RabbitMQ，一个消息处理完之后才会接受下一个消息。