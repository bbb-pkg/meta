# Setup bbb-pkg

Install apt-mirror:
```
sudo apt install apt-mirror
```

Configure apt-mirror:
```
cat << EOF > /etc/apt/mirror.list
set base_path         /vagrant/mirror
set mirror_path       $base_path/mirror
set skel_path         $base_path/skel
set var_path          $base_path/var
# set postmirror_script $var_path/postmirror.sh
set defaultarch       amd64
set run_postmirror    0
set nthreads          20
set limit_rate        100m
set _tilde            0
# Use --unlink with wget (for use with hardlinked directories)
set unlink            1
set use_proxy         off
#set http_proxy        127.0.0.1:3128
#set proxy_user        user
#set proxy_password    password

deb https://ubuntu.bigbluebutton.org/xenial-22/ bigbluebutton-xenial main

#clean http://archive.ubuntu.com/ubuntu
EOF
```

Run `apt-mirror` periodically.

### Initialization
To create folders and git repositories:
```
cat mirror/var/ALL | grep "xenial-22/" | cut -d'/' -f 7 | cut -d_ -f1 | grep bbb | xargs -n1 -i mkdir -p /vagrant/repos/{}
find /vagrant/repos/ -maxdepth 1 -mindepth 1 -type d | xargs -n1 git init
```

### Initial import
If you have already a bunch of mirrored packages, you can create yourself an import script:
```
find /vagrant/mirror/mirror/ubuntu.bigbluebutton.org/xenial-22/pool/main/ -mindepth 2 -maxdepth 2 | rev | cut -d'/' -f1 | rev | \
  grep bbb | xargs -n1 -i sh -c 'echo; echo "# "{}; find /vagrant/mirror/mirror/ubuntu.bigbluebutton.org/xenial-22/pool/main/*/{} -mindepth 1 -print0 | sort -z | xargs -r0 -n1 -I+ echo /vagrant/repo.sh + /vagrant/repos/{}' > run.sh
```

To import only one package with all versions: 
```
find /vagrant/mirror/mirror/ubuntu.bigbluebutton.org/xenial-22/pool/main/b/bbb-apps/ -mindepth 1 -print0 | sort -z | xargs -r0 -n1 -i /vagrant/repo.sh {} /vagrant/repos/bbb-apps
```

### Extract deb into repo
For extracting the debian package into a git repo, use `repo.sh`.  
This not only runs `dpkg-deb`, but also gets the timestamp and maintainer from `DEBIAN/control` and sets the git author and date correctly. The package version is also extracted from there and used as the commit message and the git tag.

