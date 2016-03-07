# 前提条件
创建dmzsz/rails image他是这个项目的基础image，以官网提供rails image添加国内的163的source, bundle install gem
```
docker build -t dmzsz/rails -f dockerfile-dmzsz_rails .
```

# 两种方式

## 方法一：只执行docker-compose run命令
### 快速开始：
  ```
  docker-compose up             # 根据dockerfile生成image，启动webservice 以及依赖的其他service
  docker-compose run db:create  # 创建数据库
  docker-compose run db:migrate # 暂时没有用这一行，还有迁移记录
  ```
### 详细讲解
  1. 运行```docker compose up``命令后网页报错是因为conf/database.yml的development的host需要将localhost修改为db
  2. docker-compose.yml 中如果不指定service的name会创建一个名字为projectname_servicename的contains,如app_web。
  >**这一条不管用，暂时弃用**
    ```
    services:
    ...
      web:
        name:  web-app
    ...
    ```
  3. 制定service web 启动，他会找到依赖的service一起启动，在此之前会根据目录中的Dockefile文件build一个app-web的的image。
  4. 启动之后，需要关闭该命令，因为应用缺少rake db:create 和rake db:migrate.
    1. 进入web容器(已经制定为web-app，容器名不能像image包含/)
    ```
    docker start web-app
    docker exec -it web-app bash
    ```
    2. 运行数据库创建和迁移
    两种方式
    第一种借助docker-compose
    ```
    docker-compose run web rake db:create
    docker-compose run web rake db:migrate
    ```
    第二种进入web容器中执行rake命令
    ```
    rake db:create
    rake db:migrate
    ```
      >#### note:
      rails 5中将rake进行了合并
      ```
      rails db:create
      rails db：migrate
      ```

## 方法二：拆分命令，使用build好的image
### 快速开始
  ```
  docker build -t dmzsz/app          # 创建image
  docker-compose up                  # 调用dmzsz/app image 创建container
  docker-compose run rails db:create # 创建数据库
  ```
### 详细讲解
  在配置service web是也可以像mysql、nginx那样指定image，这样执行``docker-compose up web``是就不会根据dockerfile创建image
  1.在放置dockerfile的目录下build image
    ```
    docker build -t dmzsz/app . #image name是dmzsz/app
    ```
  2. 修改docker-compose.yml文件，添加name属性
    ```
    services:
    ...
      web:
        image: dmzsz/rails
        name:  web-app
    ...
    ```
  3.执行``docker-compose up web``


## NOTE

  - docker-compose up 启动docker-compose中所有service
  - 当已经生成了service的容器后，修改了dockerfile或者工作目录中的文件后是不会自动自动刷新容器的，我们需哟啊使用build去重新rebuild
  ```
  Usage: build [options] [SERVICE...]

  Options:
      --force-rm  Always remove intermediate containers.
      --no-cache  Do not use cache when building the image.
      --pull      Always attempt to pull a newer version of the image
  docker-compose build
  ```
  在mac或者windows中使用了docker deamon，我在浏览器输入的地址不在是localhost:3000而是一般是name为default的deamon
  查看他的ip使用：
  ```
  docker-machine ip default
  docker-machine list # 查看所有
  ```
  一般的ip是92.168.99.100,在地址栏输入 92.168.99.100:3000就能看到结果了
  - 官方教程的流程是
  1. 根据Dockerfile创建一个image 设置好工作目录copy 进去需要的Gemfile和空文件Gemfile.lock
  2. 找到之前创建好的image，在工作目录执行``rails new``命令
  3. 修改config/database.yml中host为db,使用``docker-compose up``启动所有service
  4. 运行``docker-compose run web rake db:create``
  提到的其他注意的点是：
  1. rails new创建的目录所有者是root，使用``sudo chown -R $USER:$USER .``修改拥有者
  2. image可能没有添加javascript解析器在Gemfile中添加``gem 'therubyracer', platforms: :ruby``
  3. ``docker-machine ip MACHINE_VM``查看ip

  - 其他实用命令
  ```
  docker images                 # 查看所有images
  docker ps                     # 查看运行的containers
  docker ps -a                  # 查看所有的containers
  docker ps -aq                 # 查看所有containers的name
  docker rm $(docker ps -aq)    # 删除没有运行的containers
  docker rm -f $(docker ps -aq) # 强制删除所有的containers
  docker rmi $(docker images |grep none|awk '{print $3}') #删除创建失败的images，不成功尝试删除没用containers
  docker-compose up -d          # 后台启动services
  docker-compose stop           # 关闭所有services
  ```
