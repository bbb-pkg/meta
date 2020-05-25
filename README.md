# bbb-pkg

[These repositories](https://github.com/bbb-pkg?tab=repositories) contain extractions of most of the bbb packages from the [official ubuntu repository](https://ubuntu.bigbluebutton.org/xenial-22/).

This project exists because many of the configuration files, cronjobs and shellscripts are currently not versioned and checked into the [official bbb repositories](https://github.com/bigbluebutton).
This sadly prevents people from having an easy look into issues of these parts of an bbb installation, or simply seeing the differences of these parts for each update.

### How its made

See [setup.md](setup.md) - basically its a bunch of shellscripts taped together, the most crucial part is the usage of `apt-mirror`.

