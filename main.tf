resource "aws_instance" "foo" {
  ami           = var.ami
  instance_type = var.instance_type
  iam_instance_profie = var.iam_instance_profile
  user_data = << EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "The page was created by the user data" | sudo tee /var/www/html/index.html
EOF

  
}
