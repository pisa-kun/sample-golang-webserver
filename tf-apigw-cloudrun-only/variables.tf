variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}


variable "region" {
  description = "The region where Cloud Run and Cloud SQL are to be deployed."
  type        = string
  default     = "us-central1"
}
