provider "google" {
  project     = var.myproject
  region      = var.myregion
  zone        = var.myzone
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
