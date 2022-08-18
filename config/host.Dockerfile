# 保持和docker container内版本一致
FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /mangosteen
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
# 
WORKDIR /mangosteen
ADD mangosteen-*.tar.gz ./
# bundle安装包，只安装生成环境的
RUN bundle config set --local without 'development test'
RUN bundle install
# 运行，puma在生成环境启动项目，ENTRYPOINT：当运行docker run的时候才会执行
# 这里运行RUN bundle exec puma，会由于开启的是server，导致进程永不结束，因为server是常驻的
ENTRYPOINT bundle exec puma
# RUN bundle rails server 为在开发环境启动项目的命令