user=dzq
root=/home/$user/deploys/$version
container_name=mangosteen-prod-1
# 运行数据库的容器名，也就是将来手动输入的DB_HOST
db_container_name=db-for-mangosteen

function set_env {
  name=$1
  while [ -z "${!name}" ]; do
    echo "> 请输入 $name:"
    read $name
    sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
    echo "${name} 已保存至 ~/.bashrc"
  done
}
function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

title '设置远程机器的环境变量'
set_env DB_HOST
set_env DB_PASSWORD
set_env RAILS_MASTER_KEY

title '网络操作'
if [ ! "$(docker network ls | grep network1)" ]; then
  echo "创建network1 ..."
  docker network create network1
else
  echo "网络network1已经存在"
fi
echo '网络操作完毕！'

title '数据库操作'
if [ "$(docker ps -aq -f name=^${DB_HOST}$)" ]; then
  echo '已存在数据库'
else
  echo '创建数据库'
  docker run -d --name $db_container_name \
            --network=network1 \
            -e POSTGRES_DB=mangosteen_production \
            -e POSTGRES_USER=mangosteen \
            -e POSTGRES_PASSWORD=$DB_PASSWORD \
            -e PGDATA=/var/lib/postgresql/data/pgdata \
            -v mangosteen-data:/var/lib/postgresql/data \
            postgres:14
  echo '创建成功'
fi
echo '数据库操作完毕！'

title 'docker build'
docker build $root -t mangosteen:$version

if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
  title 'docker rm'
  docker rm -f $container_name
fi

title 'docker run'
docker run -d -p 3000:3000 \
           --network=network1 \
           --name=$container_name \
           -e DB_HOST=$DB_HOST \
           -e DB_PASSWORD=$DB_PASSWORD \
           -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
           mangosteen:$version

echo
echo "是否要更新数据库？[y/N]"
read ans
case $ans in
    y|Y|1  )  echo "yes"; title '更新数据库'; docker exec $container_name bin/rails db:create db:migrate ;;
    n|N|2  )  echo "no" ;;
    ""     )  echo "no" ;;
esac

title '删除历史tar等文件'
shopt -s extglob
cd /home/$user/deploys
rm -vrf !($version)
title '全部执行完毕'
