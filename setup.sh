# Upgrade to Java 8
sudo yum install java-1.8.0 -y
sudo yum remove java-1.7.0 -y

# Configure aws CLI
mkdir -p /home/ec2-user/.aws
echo -e "[default]\naws_access_key_id=$ACCESS_KEY\naws_secret_access_key=$SECRET_KEY\n" > /home/ec2-user/.aws/credentials
echo -e "[default]\nregion=$REGION\n" > /home/ec2-user/.aws/config

# Bring down the minecraft backup
aws s3 sync s3://minecraft.death.rocks /home/ec2-user/minecraft

sudo mv /home/ec2-user/minecraft-init /etc/init.d/minecraft
sudo chmod u+x /etc/init.d/minecraft
sudo chkconfig --add minecraft

sudo service minecraft start
