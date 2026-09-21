# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name tag for the EBS volume"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone where the volume will be created"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SIZE AND TYPE
# ------------------------------------------------------------------------------

variable "size" {
  description = "Size of the volume in GiB"
  type        = number
  default     = 8
}

variable "type" {
  description = "Volume type (gp2, gp3, io1, io2, sc1, st1, standard)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.type)
    error_message = "Volume type must be gp2, gp3, io1, io2, sc1, st1, or standard."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PERFORMANCE
# ------------------------------------------------------------------------------

variable "iops" {
  description = "IOPS for gp3, io1, or io2 volumes"
  type        = number
  default     = null
}

variable "throughput" {
  description = "Throughput in MiB/s for gp3 volumes (125-1000)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encrypted" {
  description = "Enable encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SNAPSHOT
# ------------------------------------------------------------------------------

variable "snapshot_id" {
  description = "Snapshot ID to create volume from"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MULTI-ATTACH
# ------------------------------------------------------------------------------

variable "multi_attach_enabled" {
  description = "Enable multi-attach (io1/io2 only)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ATTACHMENT
# ------------------------------------------------------------------------------

variable "attach_to_instance" {
  description = "EC2 instance ID to attach the volume to"
  type        = string
  default     = ""
}

variable "device_name" {
  description = "Device name for attachment (e.g., /dev/xvdf)"
  type        = string
  default     = "/dev/xvdf"
}

variable "force_detach" {
  description = "Force detach on destroy"
  type        = bool
  default     = false
}

variable "stop_instance_before_detaching" {
  description = "Stop instance before detaching"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FINAL SNAPSHOT
# ------------------------------------------------------------------------------

variable "final_snapshot" {
  description = "Create final snapshot on destroy"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to the volume"
  type        = map(string)
  default     = {}
}
