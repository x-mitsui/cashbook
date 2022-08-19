# 注意修改 oh-my-env 目录名为你的目录名【从第7行能看出是工作目录】
# 赋值两边是紧凑的，没有空格，书写时注意
dir=oh-my-env

time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/mangosteen-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/workspaces/$dir/mangosteen_deploy

# 删除多余的文件
yes | rm tmp/mangosteen-*.tar.gz; 
yes | rm $deploy_dir/mangosteen-*.tar.gz; 

# -c 或--create 建立新的备份文件。
# -x或--extract或--get 从备份文件中还原文件。
# -z或--gzip或--ungzip 通过gzip指令处理备份文件。
# -v或--verbose 显示指令执行过程。
# -f<备份文件>或--file=<备份文件> 指定备份文件。
# 最后*代表所有不以“.”开头的文件
# $dist为打包结果

tar --exclude="tmp/cache/*" --exclude="config/credentials/production.key" -czv -f $dist *
# p, --parents 需要时创建上层目录，如目录早已存在则不当作错误
# 将关键四个文件移动到两端共享的文件夹中
mkdir -p $deploy_dir
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
cp $current_dir/setup_host.sh $deploy_dir/
mv $dist $deploy_dir
echo $time > $deploy_dir/version
echo 'DONE!'