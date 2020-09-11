provider "google" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = "cobalt-howl-274406"
} 

provider "aws" {
  region = "ap-south-1"
  profile = "Ajay"
}

provider "kubernetes" {
  load_config_file = "false"

  host = "https://${google_container_cluster.gke.endpoint}"
  username = var.usergke
  password = var.passgke
  client_certificate = base64decode(
    google_container_cluster.gke.master_auth[0].client_certificate,
  )
  client_key = base64decode(
    google_container_cluster.gke.master_auth[0].client_key,
  )
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
  )
} 