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
  family  = "debian-11"
#  #project = "debian-cloud"
  
}

output "image_name" {
  description = "Image Name"
  value       = data.google_compute_image.my_image.name
}
