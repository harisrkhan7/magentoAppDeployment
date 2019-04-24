resource "alicloud_slb" "master" {
  name                 = "master-slb"
  internet             = true
  internet_charge_type = "paybytraffic"
  bandwidth            = 5
  specification = "slb.s1.small"
  vswitch_id = "${alicloud_vswitch.vsw.id}"
}
resource "alicloud_slb_listener" "http" {
  load_balancer_id = "${alicloud_slb.master.id}"
  health_check = "off"
  backend_port = "80"
  frontend_port = "80"
  protocol = "http"
  bandwidth = "10"
  sticky_session = "on"
  sticky_session_type = "insert"
  cookie = "testslblistenercookie"
  cookie_timeout = 86400
  acl_status                = "off"
}
