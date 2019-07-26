#!/bin/bash                                                                                                                                                                      

re='^[0-9]+$'
max=65536

printf 'votre login : '
read -r login
    if [ -z $login ]
    then
	echo "vous n'avez pas rentrer de login" >&2; exit 1
    fi
printf 'votre @IP : '
read -r IP

if [ $IP != "localhost" ]
then
    
    if ! [[ $IP =~ $re ]]
    then
	echo "IP Invalide"; >&2; exit 1
    fi
    p=$(echo $IP | cut -d "." -f 1)
    s=$(echo $IP | cut -d "." -f 2)
    t=$(echo $IP | cut -d "." -f 3)
    q=$(echo $IP | cut -d "." -f 4)
    if [[ $p =~ !$re ]]
    then
	echo "le premier octet n'est pas valide " >&2; exit 1
    fi
    if [[ $s =~ !$re ]]
    then
	echo "le second octet n'est pas valide " >&2; exit 1
    fi
    if [[ $t =~ !$re ]]
    then
	echo "le troisieme octet n'est pas valide " >&2; exit 1
    fi
    if [[ $q =~ !$re ]]
    then
	echo "le quatrieme  octet n'est pas valide" >&2; exit 1
    fi
    
    if [[ -z $p || -z $s || -z $t || -z $q ]]
    then
        echo "l'adresse ip est mauvaise " >&2; exit 1
    fi
    
    if [ $p -lt 0 ] || [ $p -gt 255 ]
    then
        echo "le premier octet n'est pas valide" >&2; exit 1
    fi
    
    if [ $s -lt 0 ] || [ $s -gt 255 ]
    then
        echo "le second octet n'est pas valide"
	exit 2
    fi
    if [ $t -lt  0 ] || [ $t -gt 255 ]
    then
        echo "le troisième octet n'est pas valide"
	exit 3
    fi
    if [ $q -lt 0 ] || [ $q -gt 255 ]
    then
        echo "le quatrieme octet n'est pas valide"
	exit 4
    fi
fi

printf 'votre numéro de port: '
read -r PORT

if ! [[ $PORT =~ $re]]  || $PORT -le $max ]] ;
then
    echo "le numero de port est incorrect " >&2; exit 1
fi

ssh -t $login@$IP -p $PORT '

passgen=`head -c 10 /dev/random | base64`
password=${passgen:0:10}
echo $password > password.txt;

sudo apt-get -y update;
sudo apt-get -yq upgrade;


sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $password";
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $password";
sudo apt-get -y install mysql-server;
sudo apt-get -y install curl ;
sudo apt-get -y install apache2;
cd /tmp;
wget http://wordpress.org/latest.zip;
sudo apt-get -y install unzip;
sudo unzip latest.zip -d /var/www/html
cd /var/www/html/
sudo rm -rf index.php;
sudo cp -R wordpress/* ./;
sudo rm -Rf wordpress;
cd /var/www/;
sudo chown -R www-data:www-data  *
sudo find . -type d -exec chmod 0755 {}\;
sudo find . -type f -exec chmod 0644 {} \;
mysql -u root --password="" -e "create database wordpress; create user miquel_m;GRANT ALL PRIVILEGES ON wordpress.* TO miquel_m@localhost;"
cd;
sudo rm /var/www/html/index.html;
sudo sh -c "echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list";                                                                                          
sudo sh -c "echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list";                                                                                          
wget https://www.dotdeb.org/dotdeb.gpg;                                                                                                                                          
sudo apt-key add dotdeb.gpg                                                                                                                                                      
sudo apt-get update;                                                                                                                                                             
sudo apt-get -y install php7.0;
sudo apt-get -y install php7.0-mysql;
sudo service apache2 restart;
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar;
chmod +x wp-cli.phar;
sudo mv wp-cli.phar /usr/local/bin/wp;
wp core download --locale=fr_FR --force;
wp core config --dbname=wordpress --dbuser=miquel_m --dbpass=lulu --skip-check --extra-php <<PHP
define( 'WP_DEBUG', true ) PHP;
wp core install --url=wp.mywebchef.org --title="titre" --admin_user=root --admin_email=matmatmi@gmail.com --admin_password="" ;
wp post create --post_type=page --post_title='Accueil' --post_status=publish;
wp post create --post_type=page --post_title='Blog' --post_status=publish;
wp post create --post_type=page --post_title='Contact' --post_status=publish;
wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish;
curl http://loripsum.net/api/5 | wp post generate --post_content --count=5;
touch password.txt
echo $password > password.txt;
echo $password;
sudo a2enmod ssl;
sudo service apache2 restart;
sudo mkdir /etc/ssl/wordpress/
netstat -tanpu | grep "LISTEN" | grep "443";
sudo service apache2 restart;
sudo openssl genrsa -des3 -out server.key 1024;
sudo openssl req -new -key server.key -out server.csr;
sudo cp server.key server.key.org;
sudo openssl rsa -in server.key.org -out server.key;
sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt;
sudo rm /var/www/index.html;
sudo service apache2 restart;
'