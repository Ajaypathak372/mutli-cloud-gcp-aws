variable "region" {
    type = string
    default = "asia-southeast1"
}

variable "name_vpc_gke" {
    type = string
    default = "developer"
}

variable "name_subnet_gke" {
    type = string
    default = "dev-subnet-1"
}

variable "gke_cluster_name" {
    type = string
    default = "my-gke-cluster"
}

variable "gke_nodepool_name" {
    type = string
    default = "my-gke-pool"
}

variable "userrds" {
    type = string
    default = "admin"
}

variable "passrds" {
    type = string
    default = "ajay1234"
}

variable "db" {
    type = string
    default = "db_gke"
}

variable "usergke" {
    type = string
    default = "master"
}

variable "passgke" {
    type = string
    default = "ajaypathak372gkecluster"
}

variable "app" {
    type = string
    default = "wordpress"
}

variable "tier" {
    type = string
    default = "frontend"
}

variable "subnet_group" {
    type = string
    default = "mysql-subnet-group"
}

variable "pvc_name" {
    type = string
    default = "pvc-wordpress"
}

variable "image_name" {
    type = string
    default = "wordpress"
}

variable "deployment_name" {
    type = string
    default = "wordpress-deploy"
}

variable "svc_name" {
    type = string
    default = "svc-wordpress"
}

variable "port_no" {            
    default = 80
}       