resource "google_compute_network" "vpc_gke" {
  name                    = var.name_vpc_gke
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = var.name_subnet_gke
  ip_cidr_range = "10.141.0.0/20"
  region        = var.region
  private_ip_google_access = true
  network       = google_compute_network.vpc_gke.id
}

resource "google_container_cluster" "gke" {
  name     = var.gke_cluster_name
  location = var.region
  initial_node_count       = 1
  remove_default_node_pool = true
  network   = var.name_vpc_gke
  subnetwork = var.name_subnet_gke
  master_auth {
    username = var.usergke
    password = var.passgke

    client_certificate_config {
      issue_client_certificate = true
    }
  }
  depends_on = [ google_compute_subnetwork.subnet1 ]
}

resource "google_container_node_pool" "node_pool" {
  name       = var.gke_nodepool_name
  location   = var.region
  cluster    = var.gke_cluster_name
  node_count = 1

  node_config {
    image_type   = "cos_containerd"
    preemptible  = true
    machine_type = "n1-standard-1"
    labels = {
      database = "rds"
    }
      metadata = {
      disable-legacy-endpoints = "true"
     }
  }
  depends_on = [ google_container_cluster.gke ]
}

data "google_compute_instance_group" "gcig_0" {
  // regex for retrieving the name of the instance group from the link
  name        = "${regex("([^/]+)/?$" , "${google_container_node_pool.node_pool.instance_group_urls.0}").0}"
  // regex for retrieving the zone of the instance group fomr the link
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.0}")}"
}

data "google_compute_instance_group" "gcig_1" {
  name        = "${regex("([^/]+)/?$" , "${google_container_node_pool.node_pool.instance_group_urls.1}").0}"
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.1}")}"
}

data "google_compute_instance_group" "gcig_2" {
  name        = "${regex("([^/]+)/?$" , "${google_container_node_pool.node_pool.instance_group_urls.2}").0}"
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.2}")}"
}

data "google_compute_instance" "node1" {
  self_link = "${sort(data.google_compute_instance_group.gcig_0.instances)[0]}"
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.0}")}"
} 

data "google_compute_instance" "node2" {
  self_link = "${sort(data.google_compute_instance_group.gcig_1.instances)[0]}"
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.1}")}"
}

data "google_compute_instance" "node3" {
  self_link = "${sort(data.google_compute_instance_group.gcig_2.instances)[0]}"
  zone        = "${regex("${var.region}-?[abc]" , "${google_container_node_pool.node_pool.instance_group_urls.2}")}"
}