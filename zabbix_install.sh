#!/bin/bash
# Owner ISTC Foundation
# Created By Vardges Hovhannisyan
#Certbot Install
#/////////////////////////////////////////////////////////
#Collection All neccessary data and configruing Variables
#/////////////////////////////////////////////////////////


#########################################################################################################
#Variables
#########################################################################################################
while getopts d:v: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
        v) yn=${OPTARG};;
    esac
done
echo "domain: $domain";
echo "yn: $yn";

zabbixconf=/etc/zabbix/zabbix_server.conf
zabbixnginx=/etc/zabbix/nginx.conf
nginxdir=/etc/nginx/sites-enabled/
#Zabbix Version Variables
zab_ub_20_5_4=https://mirror.istc.am/scripts/zabbix/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
zab_ub_18_5_4=https://mirror.istc.am/scripts/zabbix/zabbix-release/zabbix-release_5.4-1+ubuntu18.04_all.deb
zab_ub_16_5_4=https://mirror.istc.am/scripts/zabbix/zabbix-release/zabbix-release_5.4-1+ubuntu16.04_all.deb
zab_ub_14_5_4=https://mirror.istc.am/scripts/zabbix/zabbix-release/zabbix-release_5.4-1+ubuntu14.04_all.deb

zab_ub_20_5_4_deb=zabbix-release_5.4-1+ubuntu20.04_all.deb
zab_ub_18_5_4_deb=zabbix-release_5.4-1+ubuntu18.04_all.deb
zab_ub_16_5_4_deb=zabbix-release_5.4-1+ubuntu16.04_all.deb
zab_ub_14_5_4_deb=zabbix-release_5.4-1+ubuntu14.04_all.deb

zab_ub_20_5_0=https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
zab_ub_18_5_0=https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+bionic_all.deb
zab_ub_16_5_0=https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+xenial_all.deb
zab_ub_14_5_0=https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+trusty_all.deb

zab_ub_20_5_0=zabbix-release_5.0-1+focal_all.deb
zab_ub_18_5_0=zabbix-release_5.0-1+bionic_all.deb
zab_ub_16_5_0=zabbix-release_5.0-1+xenial_all.deb
zab_ub_14_5_0=zabbix-release_5.0-1+trusty_all.deb

#SSL Configuration Variables
options_ssl=https://mirror.istc.am/scripts/zabbix/options-ssl-nginx.conf
ssl_dpharams=https://mirror.istc.am/scripts/zabbix/ssl-dhparams.pem
final_nginx_zabbix=https://mirror.istc.am/scripts/zabbix/zabbix_nginx.conf


#########################################################################################################
#OS CHECK AND DISTRIBUTIVE
#########################################################################################################
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
OS=`lowercase \`uname\``
KERNEL=`uname -r`
MACH=`uname -m`

if [ "{$OS}" == "windowsnt" ]; then
    OS=windows
elif [ "{$OS}" == "darwin" ]; then
    OS=mac
else
    OS=`uname`
    if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p`
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
    elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
    elif [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
        elif [ -f /etc/mandrake-release ] ; then
            DistroBasedOn='Mandrake'
            PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
            PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
            REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
        fi
        OS=`lowercase $OS`
        DistroBasedOn=`lowercase $DistroBasedOn`
        readonly OS
        readonly DIST
        readonly DistroBasedOn
        readonly PSUEDONAME
        readonly REV
        readonly KERNEL
        readonly MACH
    fi

fi
echo $OS
echo $KERNEL
echo $MACH
echo $DIST
#########################################################################################################
#INSTALLING ZABBIX
#########################################################################################################

if [[ ${DIST} = "Ubuntu"* ]]; then
    #Installing Zabbix
    sudo wget $zab_ub_20_5_4
    sudo dpkg -i $zab_ub_20_5_4_deb
    sudo apt update -y 
    sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
    sudo apt-get install mysql-server -y
    
    elif [[ ${DIST} = "CentOS"* ]]; then
    # CentOS
    #Installing Zabbix
    sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    sudo dnf clean all -y
    dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
    dnf install -y mysql-server            
    
    elif [[ ${DIST} = "Red"* ]]; then
    # Red Hat
    #Installing Zabbix
    sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    sudo dnf clean all -y
    sudo dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
    dnf install -y mysql-server  

    elif [[ ${DIST} = "openSUSE"* ]]; then
    # openSUSE
    #Installing Zabbix
    sudo rpm -Uvh --nosignature https://repo.zabbix.com/zabbix/5.4/sles/15/x86_64/zabbix-release-5.4-1.sles15.noarch.rpm
    sudo zypper --gpg-auto-import-keys refresh 'Zabbix Official Repository'
    sudo SUSEConnect -p sle-module-web-scripting/15/x86_64
    sudo SUSEConnect --list-extensions
    zypper install zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

                             
    elif [[ ${DIST} = "Debian"* ]]; then
    # debian
    #Installing Zabbix
    sudo wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian11_all.deb
    sudo dpkg -i zabbix-release_5.4-1+debian11_all.deb
    sudo apt update -y
    sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
    sudo apt-get install mysql-server -y
fi

##############################################################################################################################
# Configuring Mysql 
##############################################################################################################################
PASSWDDB="$(< /dev/urandom tr -dc A-Za-z0-9 | head -c24; echo)"

# replace "-" with "_" for database username
MAINUSER=zabbix
MAINDB=zabbix

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /etc/mysql/my.cnf ]; then
mysql -u root <<MYSQL_SCRIPT
    CREATE DATABASE $MAINDB character set utf8 collate utf8_bin;
    CREATE USER '$MAINUSER'@'localhost' IDENTIFIED BY '$PASSWDDB';
    GRANT ALL PRIVILEGES ON $MAINDB.* TO '$MAINUSER'@'localhost';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
    zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -u root

# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
    echo "Please enter root user MySQL password!"
    echo "Note: password will be hidden when typing"
    read -sp rootpasswd
    mysql -u root -p${rootpasswd} -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -u root -p${rootpasswd} -e "CREATE USER ${MAINUSER}@localhost IDENTIFIED BY '${PASSWDDB}';"
    mysql -u root -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINUSER}'@'localhost';"
    mysql -u root -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
    echo "[mysql]" >> ~/.my.cnf
    echo "user=$MAINUSER" >> ~/.my.cnf
    echo "password=$PASSWDDB" >> ~/.my.cnf
    sudo chmod 600 ~/.my.cnf

UP=$(pgrep mysql | wc -l);
if [ "$UP" -ne 1 ];
then
        echo "MySQL is down.";
        sudo service mysql start
        sudo service mysql enable

else
        echo "All is well. and now starting to migrate database";
        zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -u $MAINUSER $MAINDB
fi

if test -f "$zabbixconf"; then
sed -i "s/# DBPassword=/DBPassword=$PASSWDDB/g" $zabbixconf
    echo "Mysql changes was done was set successfully."
else   
    echo "Cant Find server.host on $zabbixconf, or the changes have already done"
fi
if test -f "$zabbixnginx"; then
    sed -i "s/#        listen          80;/        listen          80;/g" $zabbixnginx
    sed -i "s/#        server_name     example.com;/        server_name     $domain;/g" $zabbixnginx
    systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
    systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
else   
    echo "Cant Find server.host on $zabbixnginx, or the changes have already done"
fi


########################################################################################################################
#Configuring Zabbix Services
########################################################################################################################

########################################################################################################################
#Installing Certbot and SSL
########################################################################################################################
if [[ $yn == "public" ]]; then
        
            #Getting Server IP Address
            ipaddress="$(dig @ns1-1.akamaitech.net ANY whoami.akamai.net +short)" 

            #Getting DNS Provider
            dnsserver=$(dig +short ns "$domain")

            #Comparing the IP And Domian
            checkip="$(dig +short $domain)"

            if [[ "$ipaddress" == "$checkip" ]];
                then
                    echo "////////////// S U C C E S S /////////////////" 
                    echo "//////////////////////////////////////////////"
                    echo "SUCCESS:: DNS Records Changed Successfully"
                    echo "//////////////////////////////////////////////"
                    echo "////////////// S U C C E S S /////////////////" 
                else
                    echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
                    echo "//////////////////////////////////////////////////////////////////////////////////"
                    echo "The $domain A record is not set to $ipaddress, Please Do changes And Run Again"
                    echo "//////////////////////////////////////////////////////////////////////////////////"
                    echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
                    
            fi
            if [ "$ipaddress" != "$checkip" ];
                then
                    echo ""
                    echo ""
                    echo "See Your DNS Provider below"
                    echo "$dnsserver"
                    
            fi
            #Cloudlfare DNS
            if [[ $dnsserver == *"cloudflare"* ]] && [ "$ipaddress" != "$checkip" ]; then
            echo ""
            echo ""
            printf "Please Check in Cloudlfare Documentation:\t\033[1mhttps://www.cloudflare.com/learning/dns/dns-records/dns-a-record\033[m\n"
            exit 0
            fi
            #AWS Route DNS
            if [[ $dnsserver == *"aws"* ]] && [ "$ipaddress" != "$checkip" ]; then
            echo ""
            echo ""
            printf "Please Check in AWS Route53 Documentation:\t\033[1mhttps://aws.amazon.com/ru/premiumsupport/knowledge-center/route-53-create-alias-records/\033[m\n"
            exit 0
            fi
            #Name.com DNS
            if [[ $dnsserver == *"akam"* ]] && [ "$ipaddress" != "$checkip" ]; then
            echo ""
            echo ""
            printf "Please Check in Name.com Documentation:\t\033[1mhttps://www.name.com/support/articles/115004893508-Adding-an-A-record\033[m\n"
            exit 0
            fi
            #NameCheap.com DNS
            if [[ $dnsserver == *"namecheap"* ]] || [[ $dnsserver == *"registrar-servers"* ]] || [[ $dnsserver == *"ultradns"* ]]  && [ "$ipaddress" != "$checkip" ]; then
            echo ""
            echo ""
            printf "Please Check in NameCheap Documentation:\t\033[1mhttps://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/\033[m\n"
            exit 0
            fi

            #Other DNS Providers
            if [[ $dnsserver != *"namecheap"* ]] && [[ $dnsserver != *"registrar-servers"* ]] && [[ $dnsserver != *"ultradns"* ]] && [[ $dnsserver != *"namecheap"* ]] && [[ $dnsserver != *"akam"* ]] && [[ $dnsserver != *"cloudflare"* ]] && [[ $dnsserver != *"aws"* ]]  && [ "$ipaddress" != "$checkip" ]; then
            echo ""
            echo ""
            printf "Please Check in NameCheap Documentation:\t\033[1mhttps://docs.digitalocean.com/products/networking/dns/how-to/manage-records/\033[m\n"
            exit 0
            fi


            if [[ ${DIST} = "Ubuntu"* ]]; then
                #Installing Certbot 
                sudo snap install core
                sudo snap install --classic certbot
                sudo ln -s /snap/bin/certbot /usr/bin/certbot

            elif [[ ${DIST} = "CentOS"* ]]; then
                # CentOS
                #Installing Snapd
                sudo yum install epel-release
                sudo yum install snapd
                sudo systemctl enable --now snapd.socket
                sudo ln -s /var/lib/snapd/snap /snap

                #Installing Certbot
                sudo snap install core
                sudo snap install --classic certbot
                sudo ln -s /snap/bin/certbot /usr/bin/certbot

            elif [[ ${DIST} = "Red"* ]]; then
                # Red Hat
                #Installing Snapd
                sudo yum install epel-release
                sudo yum install snapd
                sudo systemctl enable --now snapd.socket
                sudo ln -s /var/lib/snapd/snap /snap

                #Installing Certbot
                sudo snap install core
                sudo snap install --classic certbot
                sudo ln -s /snap/bin/certbot /usr/bin/certbot

            elif [[ ${DIST} = "openSUSE"* ]]; then
                # openSUSE
                #Installing Snapd
                sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_15.2 snappy
                sudo zypper --gpg-auto-import-keys refresh
                sudo zypper dup --from snappy
                sudo zypper install snapd
                source /etc/profile
                sudo systemctl enable --now snapd
                sudo systemctl enable --now snapd.apparmor

                #Install Certbot
                sudo snap install core
                sudo snap install --classic certbot
                sudo ln -s /snap/bin/certbot /usr/bin/certbot
                             
            elif [[ ${DIST} = "Debian"* ]]; then
                # debian
                    #Installing Certbot 
                    sudo snap install core
                    sudo snap install --classic certbot
                    sudo ln -s /snap/bin/certbot /usr/bin/certbot

            fi
            

            webservice="nginx"
            if [ -f /var/run/nginx.pid ]; then
            echo "Nginx is running"
                else (
                    echo "You have problem With Nginx, Please Solve the problem and run the script again"
                    nginx -t
                )
            fi
            #Creating SSL with Certbot
            if pgrep -x "$webservice" >/dev/null
                then
                    certbot certonly -d $domain --agree-tos --manual-public-ip-logging-ok --webroot -w /usr/share/zabbix/ --server https://acme-v02.api.letsencrypt.org/directory --register-unsafely-without-email --rsa-key-size 4096
                else
                    echo "$webservice not running"
                    exit 0
            fi
            if test -f "$zabbixnginx"; 
                then
                    sudo rm $zabbixnginx
                    sudo wget $final_nginx_zabbix -O /etc/zabbix/nginx.conf
                    sed -i "s/mydomain/$domain/g" $zabbixnginx
                    sudo wget $options_ssl -O /etc/letsencrypt/options-ssl-nginx.conf
                    sudo wget $ssl_dpharams -O /etc/letsencrypt/ssl-dhparams.pem
                else   
                    echo "Cant Find server.host on $zabbixnginx, or the changes have already done"
            fi
    

            if [ -f /var/run/nginx.pid ]; then
            echo "Nginx is running"
                else
                    echo "You have problem With Nginx, Please Solve the problem and run the script again"
                    nginx -t
            fi
    
    else 
            echo "Ok We Will Install only Zabbix"
    fi
                    systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
                    systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm

# Printing The Password
            if [ -f /var/run/nginx.pid ]; then
                    echo "////////////// S U C C E S S /////////////////" 
                    echo "//////////////////////////////////////////////"
                    echo "Pleace Set the password in WEB UI for Mysql is:  $PASSWDDB"
                    echo "//////////////////////////////////////////////"
                    echo "////////////// S U C C E S S /////////////////" 
                else
                    echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
                    echo "//////////////////////////////////////////////////////////////////////////////////"
                    echo "The Project Was not working"
                    echo "//////////////////////////////////////////////////////////////////////////////////"
                    echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
                    
            fi
            
