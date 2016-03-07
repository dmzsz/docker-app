FROM dmzsz/rails
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev vim
RUN gem sources --add https://ruby.taobao.org --remove https://rubygems.org/
RUN bundle config mirror.https://rubygems.org https://ruby.taobao.org	
RUN mkdir  -p /var/www/myapp
WORKDIR /var/www/myapp
ADD Gemfile /var/www/myapp/Gemfile
ADD Gemfile.lock /var/www/myapp/Gemfile.lock
RUN bundle install
ADD . /var/www/myapp
