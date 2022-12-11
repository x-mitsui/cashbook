# 注意修改 user 和 服务器公用ip或ip别名
user=dzq
ip=59.110.140.199

time=$(date +'%Y%m%d-%H%M%S')
cache_dir=tmp/deploy_cache
dist=$cache_dir/mangosteen-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/home/$user/deploys/$time
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock
vendor_dir=$current_dir/../vendor
vendor_1=rspec_api_documentation
api_dir=$current_dir/../doc/api

function title {
  # 回车
  echo 
  # 80个“#”
  echo "###############################################################################"
  # 打印命令的第一个参数
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

title '运行测试用例'
rspec || exit 1
title '重新生成文档'
bin/rails docs:generate || exit 2

mkdir -p $cache_dir
title '打包源代码'
tar --exclude="tmp/cache/*" --exclude="tmp/deploy_cache/*" --exclude="vendor/*" -cz -f $dist *
title "打包本地依赖 ${vendor_1}"
# 将ruby依赖包缓存到本地
bundle cache --quiet
tar -cz -f "$vendor_dir/cache.tar.gz" -C ./vendor cache
tar -cz -f "$vendor_dir/$vendor_1.tar.gz" -C ./vendor $vendor_1

title '创建远程目录'
# 注意-p参数的作用
ssh $user@$ip "mkdir -p $deploy_dir/vendor"
title '上传源代码和依赖'
scp $dist $user@$ip:$deploy_dir/
yes | rm $dist
# scp=ssh copy
scp $gemfile $user@$ip:$deploy_dir/
scp $gemfile_lock $user@$ip:$deploy_dir/
# 文件夹加-r，涉及到递归拷贝
scp -r $vendor_dir/cache.tar.gz $user@$ip:$deploy_dir/vendor/
yes | rm $vendor_dir/cache.tar.gz
scp -r $vendor_dir/$vendor_1.tar.gz $user@$ip:$deploy_dir/vendor/
yes | rm $vendor_dir/$vendor_1.tar.gz
title '上传 Dockerfile'
scp $current_dir/../config/host.Dockerfile $user@$ip:$deploy_dir/Dockerfile
title '上传 setup 脚本'
scp $current_dir/setup_remote.sh $user@$ip:$deploy_dir/
title '上传 API 文档'
scp -r $api_dir $user@$ip:$deploy_dir/
# $time为本地的time，上传到远程的version
title '上传版本号'
ssh $user@$ip "echo $time > $deploy_dir/version"
title '执行远程脚本'
ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/setup_remote.sh"
