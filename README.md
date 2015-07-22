# Installation

## Production

### Update the system and install dependencies (as user with sudo access)

```
# Update the system
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

# Install system utils
sudo apt-get install git build-essential nginx

# Install dependencies for rbenv and ruby-build
sudo apt-get install build-essential autoconf libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev

# Install dependencies for Heritage Cookbook app
sudo apt-get install imagemagick libxml2-dev libxslt1-dev libmysqlclient-dev

# Restart the host (only needed if the kernel has been uploaded)
sudo reboot
```

Source: 
* [Ruby Build Wiki](https://github.com/sstephenson/ruby-build/wiki)

### Create a dedicated system user and log as it (as user with sudo access)

```
sudo mkdir -p /srv/app
sudo useradd --system --shell /bin/bash --home-dir /srv/app/heritage --create-home --comment 'Heritage Cookbook application' heritage
sudo su - heritage
```

### Install ruby stack (as app user)

```
# Install rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
```

You must restart your shell.

```
# Install ruby-build
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install the Heritage Cookbook app version of ruby and set it as default
rbenv install 2.0.0-p0
rbenv global 2.0.0-p0

# Install system gems
gem install bundler # Package dependencies
gem install foreman # Procfile manager
rbenv rehash
```

Source:
* [Rbenv installation guide](https://github.com/sstephenson/rbenv#readme)
* [Ruby Build installation guide](https://github.com/sstephenson/ruby-build#readme)

### Generate SSH deployment keys (as app user)

```
ssh-keygen -q -t rsa -C "Heritage Cookbook deployment key"
```

Add the public key as a [deployment key on github](https://help.github.com/articles/managing-deploy-keys#deploy-keys)

### Install Heritage Cookbook rails app and start the services (as app user)

```
# Clone the app
git clone git@github.com:heritagecookbook/heritage-cookbook.git
cd heritage-cookbook

# Install gems dependencies
bundle install --path vendor/bundle --without development test

# Precompile assets
bundle exec rake assets:precompile

# Generate an environment file
touch ~/.env
cat > ~/.env <<EOF
RACK_ENV=production
RAILS_ENV=production
SKIP_IMAGE_NOT_FOUND=true
EOF

# Generate upstart scripts using the Procfile and the .env file
mkdir /tmp/upstart-scripts
foreman export --app heritage --log ${HOME}/heritage-cookbook/log --env ${HOME}/.env --user heritage --procfile ${HOME}/heritage-cookbook/Procfile upstart /tmp/upstart-scripts
```

Start a new console with sudo access to copy the generated init file into `/etc/init`:

```
sudo chmod 644 /tmp/upstart-scripts/*
sudo chown root:root /tmp/upstart-scripts/*
sudo mv /tmp/upstart-scripts/* /etc/init
```

### Configure NGINX as a reverse proxy and start the rails app (as user with sudo access)

```
sudo su
sudo cat > /etc/nginx/sites-available/heritage <<EOF

upstream heritage {
  server unix:/srv/app/heritage/heritage-cookbook/tmp/sockets/unicorn.sock;
}

server {
  server_name my.heritagecookbook.com lb.heritagecookbook.com;
  root /srv/app/heritage/heritage-cookbook/public;
  error_page 504 http://heritagecookbook.com/maintenance/;
  error_page 502 http://heritagecookbook.com/maintenance/;
  client_max_body_size 15M;

  # Let NGINX manage sent file by the rails app
  location /pdf/ {
    alias /srv/app/heritage/heritage-cookbook/public/pdf_previews/;
    internal;
  }

  location / {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_set_header X-Accel-Mapping /srv/app/heritage/heritage-cookbook/public/pdf_previews/=/pdf/;
    proxy_read_timeout 180s;

    if (!-f \$request_filename) {
      proxy_pass http://heritage;
      break;
    }
  }
}

EOF
exit
sudo ln -s /etc/nginx/sites-available/heritage /etc/nginx/sites-enabled/heritage
sudo service nginx restart
sudo service heritage start
```

### Configure Heritage Cookbook sheduled jobs (as app user)

Use `contab -e` to define sheduled jobs

```
# Heritage Cookbook - Process order every 6 hours
1 0 * * * /srv/app/heritage/current/script/run_pdf_generation production
1 6 * * * /srv/app/heritage/current/script/run_pdf_generation production
1 12 * * * /srv/app/heritage/current/script/run_pdf_generation production
1 18 * * * /srv/app/heritage/current/script/run_pdf_generation production

# Heritage Cookbook - Process maintenance at 8AM UTC
0 8 * * * /srv/app/heritage/current/script/maintenance production

# Heritage Cookbook - Memory leaks in worker, restart every 12 hours until resolved
PATH=/usr/sbin:/usr/bin:/sbin:/bin
0 1,13 * * * service heritage-worker restart
```

### Configure log rotation

```
sudo su
cat > /etc/logrotate.d/heritage <<EOF
/srv/app/heritage/heritage-cookbook/log/*.log {
    daily
    missingok
    rotate 36
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF
exit
```

### Configure Newrelic monitoring (as user with sudo access)

```
# Add NewRelic apt repository
sudo su
echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list
wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
exit
sudo apt-get update
sudo apt-get install newrelic-sysmond
sudo nrsysmond-config --set license_key=XXXXXXXXXXX
sudo service newrelic-sysmond start
```

Source:
* [Get started with Server Monitoring on NewRelic account](https://rpm.newrelic.com/accounts/XXXXXX/servers/get_started#platform=debian)