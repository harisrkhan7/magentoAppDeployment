data "alicloud_db_instances" "db_instances_ds" {
  name_regex = "data-\\d+"
  status     = "Running"
  tags       = <<EOF
{
  "type": "database",
  "size": "small"
}
EOF
}
resource "alicloud_db_instance" "master" {
    engine = "MySQL"
    engine_version = "5.7"
    instance_type = "rds.mysql.t1.small"
    instance_storage = "30"
    vswitch_id = "${alicloud_vswitch.vsw.id}"
    security_ips = ["0.0.0.0/0"]

}
resource "alicloud_db_database" "default" {
    instance_id = "${alicloud_db_instance.master.id}"
    name = "tf_database_demo"
    character_set = "utf8"
}
resource "alicloud_db_connection" "default" {
    instance_id = "${alicloud_db_instance.master.id}"
    connection_prefix = "alicloud_demo"
    port = "3306"
}
resource "alicloud_db_account" "default" {
    instance_id = "${alicloud_db_instance.master.id}"
    name = "${var.magento_db_user}"
    password = "${var.magento_db_password}"
}
resource "alicloud_db_account_privilege" "default" {
    instance_id = "${alicloud_db_instance.master.id}"
    account_name = "${alicloud_db_account.default.name}"
    privilege = "ReadWrite"
    db_names = ["${alicloud_db_database.default.name}"]
}
