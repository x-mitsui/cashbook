DB_PASSWORD=123456
container_name=mangosteen-prod-1

# version由1.1.1文件创建
# 省去了数据库的创建，直接使用之前在本地创建的数据库
version=$(cat mangosteen_deploy/version)

echo 'docker build ...'
docker build mangosteen_deploy -t mangosteen:$version
if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
echo 'docker rm ...'
docker rm -f $container_name
fi

echo 'docker run ...'
docker run -d -p 3000:3000 \
--name=$container_name \
-e DB_HOST=$DB_HOST \
-e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
-e DB_PASSWORD=$DB_PASSWORD \
--network=network1 \
mangosteen:$version
echo 'DONE!'