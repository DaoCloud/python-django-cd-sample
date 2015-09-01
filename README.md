## 如何配置一个 Docker 化持续集成的 Django 开发环境

> 目标：我们将实现一个  **Django + MySQL + Redis**  留言板应用 ， 并创建持续集成环境。
> 
> 本项目代码维护在 **DaoCloud/django-redis-mysql-sample** 项目中 。



工欲善其器 ，必先利其器 。首先 ，你需要安装

``` sh
docker >= 1.6
docker-compose >= 1.4.0
docker-machine >= 0.4.1 (可选)
```



> Docker现在已经推出编排工具包，这些工具可以简单的编排（orchestration ）Docker实例、集群以及容器管理。它们是： 
> 
> 	[Docker Machine](https://docs.docker.com/machine/)     - 快速安装部署 Docker 。
> 
> 	[Docker Compose](https://docs.docker.com/compose/)   - 轻松编排多容器组成的应用程序 。
> 
> 	[Docker Swarm](https://docs.docker.com/swarm/)        - Docker 集群的编排和调度 。
> 
> 
> 
> 如果把docker比喻成交响乐里面的各种乐器，那么这三个工具相当于指挥。
> 
> 	Docker Machine	  - 指挥docker乐器的安置和摆放。
> 
> 	Docker Compose	  - 指挥每个docker的弹奏方式；
> 
> 	Docker Swarm	  - 指挥docker乐器的分工管理；



#### 通过 Docker Machine 安装并启动 Docker

> 若您的系统已经安装好 Docker ， 请跳至下个章节

我们通过运行：

``` sh
$ docker-machine create -d virtualbox dev;
INFO[0000] Creating CA: /Users/michael/.docker/machine/certs/ca.pem
INFO[0000] Creating client certificate: /Users/michael/.docker/machine/certs/cert.pem
INFO[0001] Downloading boot2docker.iso to /Users/michael/.docker/machine/cache/boot2docker.iso...
INFO[0035] Creating SSH key...
INFO[0035] Creating VirtualBox VM...
INFO[0043] Starting VirtualBox VM...
INFO[0044] Waiting for VM to start...
INFO[0094] "dev" has been created and is now the active machine.
To point your Docker client at it, run this in your shell: eval "$(docker-machine env dev)"
```

`create`命令 启动了一台新的 `Machine`(名字叫 dev) . 他通过下载 boot2docker 和 启动 VM 来安装和启动 Docker

现在让 Docker Client 控制

``` sh
$ eval "$(docker-machine env dev)"
```

我们可以通过

``` sh
docker-machine ip dev
docker-machine ssh dev
```

查看 dev 的 ip 和 通过 ssh 登录上 dev 。

#### Docker Compose

Docker Compose 是 官方提供的编排工具，通过 YML 文件来定义容器应用的服务配置 。

``` dockerfile
web:
  build: ./web
  ports:
    - "8000:8000"
  links:
    - mysql:mysql
    - redis:redis
  volumes:
    - ./web:/code
  env_file: .dev_env
  command: /code/manage.py runserver 0.0.0.0:8000

mysql:
  image: mysql:latest
  environment:
    - MYSQL_DATABASE=django
    - MYSQL_ROOT_PASSWORD=mysql
  ports:
    - "3306:3306"

redis:
  image: redis:latest
  ports:
    - "6379:6379"

```

我们定义了 3 个 服务- web , mysql , redis	





> web 服务
> 
> ``` dockerfile
> 00  web:
> 01    build: ./web 
> 02    ports:
> 03      - "8000:8000"
> 04    links:
> 05      - mysql:mysql
> 06      - redis:redis
> 07    volumes: 
> 08      - ./web:/code
> 09    env_file: .dev_env 
> 10    command: /code/manage.py runserver 0.0.0.0:8000
> ```
> 
> 
> 01 . 通过 ./web 路径下的 dockefile 构建
> 
> 02 . 开放端口 8000   
> 
> 03 . 与 mysql 和 redis 服务建立连接 
> 
> 07 . 将 ./web 路径 挂载到容器内的/code 目录 ，实现容器内外的数据共享
> 
> 08 . 设置环境变量
> 
> .dev_env
> 
> ``` 
> # Add Environment Variables
> # Django SECRET_KEY
> SECRET_KEY=5(15ds+i2+%ik6z&!yer+ga9m=e%jcqiz_5wszg)r-z!2--b2d
> # Django MYSQL CONFIG
> DB_NAME=django
> DB_USER=root
> DB_PASS=mysql
> DB_HOST=mysql
> DB_PORT=3306
> ```
> 
> 10 . 运行命令 （优先于 Dockerfile 中的定义）启动 Django



现在 ， 让我们的服务构建并运行起来

``` shell
docker-compose build
docker-compose up -d
```

如果是第一次构建 ，要耐心的等待一会哦 。

> 因所有官方镜像均位于境外服务器，为了确保所有示例能正常运行 。强力推荐使用 [Dao ToolBox](http://blog.daocloud.io/toolbox/) ， 快速下载该教程所需的 Python:2.7 , mysql:latest , redis:latest 镜像



第一次运行应用 ，别忘记初始化数据库哦

``` dockerfile
 docker-compose run web /code/manage.py migrate
```



通过

``` 
docker-machine ip dev
```

得到应用的 ip ， 输入 ip:8000 即可在浏览器中看到





通过

``` 
docker-compose ps
           Name                         Command               State           Ports
--------------------------------------------------------------------------------------------
pythondjangosample_mysql_1   /entrypoint.sh mysqld            Up      0.0.0.0:3306->3306/tcp
pythondjangosample_redis_1   /entrypoint.sh redis-server      Up      0.0.0.0:6379->6379/tcp
pythondjangosample_web_1     /code/manage.py runserver  ...   Up      0.0.0.0:8000->8000/tcp
```

查看启动的服务



通过

``` 
docker-compose logs
docker-compose logs web
```

查看日志



Good ! 您的 Docker 化持续集成的 Django 开发环境就搭建好了 。之后我们会手把手教你 ，如何实现 Django 应用的持续集成（ CI ）和持续部署 （ CD ）



Docker 使用介绍

- 了解更多的 Docker Compose 的命令 [Docker Compose](http://help.daocloud.io/features/docker_compose_yml.html)


