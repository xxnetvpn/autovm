provider "google" {
  project     = var.my_project
  region      = var.my_region
  zone        = var.my_zone
}

data "google_compute_image" "my_image" {
  most_recent = true
  family  = "debian-11"
  #project = "debian-cloud"
  
}

output "image_name" {
  description = "Image Name"
  value       = data.my_image.name
}
