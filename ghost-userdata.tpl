#!/bin/bash
# https://github.com/KPRepos/ghost-blog-aws
sudo apt-get update
sleep 10

while ! command -v aws &> /dev/null; do
    echo "AWS CLI not found. Installing..."

    # Update the package list
    sudo apt-get update

    # Install AWS CLI
    sudo apt-get install awscli -y

    if ! command -v aws &> /dev/null; then
        echo "AWS CLI installation failed. Retrying in 10 seconds..."
        sleep 10
    fi
done

echo "AWS CLI is already installed."

# sudo adduser blogadmin  

sudo adduser --disabled-password --gecos "" blogadmin  #naming the new user blog
sudo usermod -aG sudo blogadmin #adding user blog the sudoers group

#install NGINX
apt-get install nginx -y 

#Allow inbound firewall connections
ufw allow 'Nginx Full'

#Install MySQL
apt-get install mysql-server -y

# Wait for MySQL service to start
while ! systemctl is-active --quiet mysql; do
    sleep 1
done

# Genarate MYSQL password
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 12)

echo "------ MY-SQL ------"
echo $MYSQL_ROOT_PASSWORD
echo "--------------"

mysql --user="root" --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

echo $REGION

# Save the join command to AWS Secrets Manager
aws secretsmanager update-secret --secret-id "mysql_password" \
    --description "mysql db password" \
    --secret-string "$MYSQL_ROOT_PASSWORD" --region "$REGION"


#Add the NodeSource APT repository for Node 12
# https://ghost.org/docs/faq/node-versions/
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash

#Install Node.js
apt-get install -y nodejs

#Install Ghost-CLI
npm install ghost-cli@latest -g



USERNAME="blogadmin"  # Hardcoded username
BlogAdmin_PASSWORD=$(openssl rand -base64 12)  
 # Password still passed as a variable

echo "########### BlogAdmin_PASSWORD ##################"
echo $BlogAdmin_PASSWORD
### Change the password
echo "########### BlogAdmin_PASSWORD ##################"


echo "$${USERNAME}:$${BlogAdmin_PASSWORD}" | sudo chpasswd
echo "blogadmin ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/blogadmin > /dev/null

# Save the join command to AWS Secrets Manager
aws secretsmanager update-secret --secret-id "blogadmin_password" \
    --description "blogadmin user password" \
    --secret-string "$BlogAdmin_PASSWORD" --region "$REGION"


# We'll name ours 'ghost' in this example; you can use whatever you want
sudo mkdir -p /var/www/ghost

# Replace <user> with the name of your user who will own this directory
sudo chown blogadmin:blogadmin /var/www/ghost

# Set the correct permissions
sudo chmod 775 /var/www/ghost

# Then navigate into it
cd /var/www/ghost

sudo useradd --system --user-group ghost

echo "------- Install Ghost ------"


echo "$MYSQL_ROOT_PASSWORD" > /tmp/mysql_password
chown blogadmin /tmp/mysql_password
chmod 600 /tmp/mysql_password

ls -al /tmp/mysql_password

create_ip_only_setup="${create_ip_only_setup}"



if [ $create_ip_only_setup = "true" ]; then
    echo "Configuring Ghopst for IP only method"
    sudo -u blogadmin -i <<'EOF'

PASSWORD_FILE="/tmp/mysql_password"
MYSQL_ROOT_PASSWORD=$(cat $PASSWORD_FILE)

echo "############  #################"
echo $MYSQL_ROOT_PASSWORD
echo "############  ################"

# Fetch the public IP address from EC2 instance metadata

PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
echo "#############################"
echo "My public IP is: $PUBLIC_IP"
echo $PUBLIC_IP
URL="http://$${PUBLIC_IP}"


cd /var/www/ghost && ghost install --no-prompt --setup-mysql --setup-nginx --setup-systemd --db mysql --dbhost localhost --dbuser root --dbpass $MYSQL_ROOT_PASSWORD --dbname ghost_prod --process systemd --enable --no-stack --url "$URL" --start --auto true

EOF

    rm /tmp/mysql_password

    echo " ------- Done  ------"


else

    echo "Configuring Ghopst for DNS  method"

    sudo -u blogadmin -i <<'EOF'

PASSWORD_FILE="/tmp/mysql_password"
MYSQL_ROOT_PASSWORD=$(cat $PASSWORD_FILE)

echo "############  #################"
echo $MYSQL_ROOT_PASSWORD
echo "############  ################"

URL="${ghost_url_domain}"
EMAIL="${ghost_ssl_email}"
echo $URL
echo $EMAIL
echo "#############################"

cd /var/www/ghost && ghost install --no-prompt --setup-mysql --setup-nginx --setup-systemd --db mysql --dbhost localhost --dbuser root --dbpass $MYSQL_ROOT_PASSWORD --dbname ghost_prod --process systemd --enable --no-stack --url "$URL" --sslemail "$EMAIL" --start --auto true

EOF

    rm /tmp/mysql_password

    echo " ------- Done ------"

fi
