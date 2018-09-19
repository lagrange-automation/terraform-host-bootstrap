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

variable "activate_apis" {
  type        = "list"
  description = "A list of APIs to activate on the host project. The host project must have APIs activated for every API that service projects will use."
  default     = []
}
