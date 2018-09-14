# kubectl-with-gotty
A kubectl docker image using gotty for remote connection with tls

## 证书生成


  > [OpenSSL生成根证书CA及签发子证书](https://my.oschina.net/itblog/blog/651434)

[使用 openSSL 实现CA](http://blog.51cto.com/vinsent/1964034)

## 镜像构建

```
./docker-build-tools.sh
./docker-build-gotty-kubectl.sh
```

## 镜像运行

```
docker run -d -p 8080:8080 --name kubectl cwocwo/alpine-kubectl-with-gotty:1.0.0
```
