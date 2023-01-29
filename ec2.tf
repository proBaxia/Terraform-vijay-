provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install epel -y",
      "sudo yum install httpd -y",
      "sudo chmod -Rf 777 /var/www/html",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"

    ]
  }
  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"
  }

}