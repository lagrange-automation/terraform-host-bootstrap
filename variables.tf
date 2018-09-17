variable "name" {
  type        = "string"
  description = "The name attached to host project resources"
}

variable "organization_id" {
  type        = "string"
  description = "The GCP organization ID"
}

variable "billing_account" {
  type        = "string"
  description = "The billing account ID to associated with bootstrapped resources"
}
