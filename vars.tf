variable "region" {
    type="string"
    default="ap-southeast-2" 
}
variable "switch_region" {
    type="string"
    default="ap-southeast-2a"
  
}
variable "magento_public_key" {
  type="string"  
}
variable "magento_private_key" {
  type="string"
}
variable "magento_admin_first_name" {
  type="string"
  default = "FirstName"
}
variable "magento_admin_last_name" {
  type="string"
  default = "LastName"
}
variable "magento_admin_email" {
  type="string"
  default = "email@domain.com"
}
variable "magento_admin_username" {
  type="string"
  default = "admin"
}
#Password must be 7 characters long
#Password must be alphanumeric
variable "magento_admin_password" {
  type = "string"
  default = "admin123"
}
variable "magento_language" {
  type="string"
  default = "en_US"
}
variable "magento_currency" {
  type="string"
  default= "USD"
  
}
variable "magento_timezone" {
  type="string"
  default="America/Chicago"
}
variable "magento_db_user" {
    type = "string"
}
variable "magento_db_password" {
  type ="string"
}
variable "magento_backend_frontname" {
  type = "string"
}

