
variable "alarm_name_prefix" {
  type        = string
  description = "Prefix of alarm name"
}

variable "input" {
  type        = string
  description = "Path to yaml file"
}

variable "loop" {
  type        = any
  description = "loop block in yaml file "
  default     = {}
}

variable "current_environment" {
  type        = string
  description = "Current environment"
}

variable "template_data" {
  type        = any
  description = "values to replace in template"
  default     = {}
}

variable "alarm_actions" {
  type        = map(any)
  description = "map of alarm actions"
  default     = {}
}

locals {
  CloudWatch = yamldecode(templatefile(var.input, var.template_data))
}
