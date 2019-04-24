data "template_file" "provisionMagento" {
  template = "${file("installMagento.sh")}"
  vars = {
    PORT_RANGE = "${alicloud_security_group_rule.allow_all_tcp.port_range}"
    MAGENTO_REPO_USERNAME = "${var.magento_public_key}"
    MAGENTO_REPO_PASSWORD = "${var.magento_private_key}"

    DB_HOST = "${alicloud_db_connection.default.ip_address}"
    DB_NAME = "${alicloud_db_database.default.name}"
    DB_USER = "${alicloud_db_account.default.name}"
    DB_PASSWORD = "${alicloud_db_account.default.password}"
    HOST_NAME = "${alicloud_slb.master.address}"

    REDIS_HOST_NAME = "${alicloud_kvstore_instance.redisCache.connection_domain}"
    REDIS_HOST_PASSWORD = "${alicloud_kvstore_instance.redisCache.password}"

    ADMIN_FIRST_NAME = "${var.magento_admin_first_name}"
    ADMIN_LAST_NAME = "${var.magento_admin_last_name}"
    ADMIN_EMAIL = "${var.magento_admin_email}"
    ADMIN_USERNAME = "${var.magento_admin_username}"
    ADMIN_PASSWORD = "${var.magento_admin_password}"
    BACKEND_FRONTNAME = "${var.magento_backend_frontname}"
    LANGUAGE = "${var.magento_language}"
    CURRENCY = "${var.magento_currency}"
    TIME_ZONE = "${var.magento_timezone}"
  }
}
