variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "repository_name" {
  description = "The Artifact Registry repository name where Docker images will be stored."
  type        = string
}

variable "job_repository_name" {
  description = "The Artifact Registry repository name where Docker images will be stored."
  type        = string
}

variable "image_name" {
  description = "The name of the Docker image to be used in Cloud Run."
  type        = string
}

variable "job_image_name" {
  description = "The name of the Docker image to be used in Cloud Run."
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL PostgreSQL instance."
  type        = string
}

variable "db_name" {
  description = "The name of the database to be created in Cloud SQL."
  type        = string
}

variable "db_user" {
  description = "The user name for connecting to the Cloud SQL database."
  type        = string
}

variable "db_password" {
  description = "The password for the Cloud SQL database user."
  type        = string
}

variable "region" {
  description = "The region where Cloud Run and Cloud SQL are to be deployed."
  type        = string
  default     = "us-central1"
}

variable "vpc_network" {
  description = "The VPC network to be used for Cloud SQL and Cloud Run connection."
  type        = string
  default     = "default"
}
