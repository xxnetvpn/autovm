provider "google" {
  #project     = var.myproject
  #region      = var.myregion
  #zone        = var.myzone
  add_terraform_attribution_label               = true
  terraform_attribution_label_addition_strategy = "CREATION_ONLY"
  #terraform_attribution_label_addition_strategy = "PROACTIVE"
}

data "google_compute_image" "my_image" {
  most_recent = true
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
  
}

output "image_name" {
  description = "Image Name"
  value       = data.google_compute_image.my_image.name
}

# 获取最新 Ubuntu 22.04 LTS x64 镜像
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# 创建 VM 实例
resource "google_compute_instance" "ubuntu_vm" {
  name         = "tf-ubuntu2204-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network       = "default"
    access_config {} # 动态公网 IP
  }

  tags = ["tf-allow-all"]

  metadata_startup_script = file("startup.sh")
  #metadata_startup_script = <<-EOT
  #  #!/bin/bash
  #  echo "Ubuntu 22.04 VM is up" > /var/log/startup.log
  #EOT
}

# 创建防火墙规则：允许所有入站流量
resource "google_compute_firewall" "allow_all_inbound" {
  name    = "tf-allow-all-inbound"
  network = "default"

  allow {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tf-allow-all"]
}

# 创建防火墙规则：允许所有出站流量（通常默认允许）
resource "google_compute_firewall" "allow_all_egress" {
  name    = "tf-allow-all-egress"
  network = "default"

  allow {
    protocol = "all"
  }

  direction        = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags      = ["tf-allow-all"]
}


