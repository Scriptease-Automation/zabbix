# Zabbix Automation

Zabbix installer for Ubuntu, Debian, CentOS, RHEL and OpenSUSE.

This script lets you set up your own Zabbix server in a couple of minutes, using your desired parameters. It is designed to be as user-friendly as possible, requiring minimum experience.

### Installation	

1. Download the installer script

```
curl -O https://raw.githubusercontent.com/Scriptease-Automation/Zabbix/master/zabbix_install.sh
```

2. Make it executable

```
chmod +x zabbix_install.sh
```

3. Run the installer

```
bash ./zabbix_install.sh -d <your domain> -v public
```

OR

```
bash ./zabbix_install.sh -v private
```
