provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "kubernetes_server" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.medium"
  vpc_security_group_ids = ["sg-042e7c08102a1660a"]
  key_name = "virginia"

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "kubernetes-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install docker.io -y",
      "wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo systemctl start docker",
      "sudo chmod +x minikube-linux-amd64",
      "sudo cp minikube-linux-amd64 /usr/local/bin/minikube",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/stable.txt",
      "sudo chmod +x kubectl",
      "sudo cp kubectl /usr/local/bin/kubectl",
      "sudo groupadd docker",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./virginia.pem")
  }
  provisioner "remote-exec" {
     inline = ["echo 'wait to start the instance' "]
  }
  tags = {
     Name = "kubernetes-server"
     }
  provisioner "local-exec" {
     command = "echo ${aws_instance.kubernetes-server.public_ip} > inventory"
     }
  provisioner "local-exec" {
     command = "ansible-playbook /var/lib/jenkins/workspace/Medicure_healthcare_Project/terraform-files/ansibleplaybook.yml"
     }
}
