先启动一个fireflyiii容器
```
docker run \
 -d \
 -p 888:8080  \
 -p 889:8443 \
 -p 887:9000   \
 --name fireflyiii \
 -e APP_KEY=x0H3fQQfljyVME5eFGmIokY18anllBIh \
 -e DB_CONNECTION=sqlite  \
 fireflyiii/core:latest
```
点开配置给变量赋值
```
TARGET_URL=fireflyiii地址及端口 #列：http://192.168.1.100:888
```
