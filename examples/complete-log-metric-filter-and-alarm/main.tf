module "ncfx-metric-alarm" {
  source = "../"

  input               = "${path.module}/path to yaml file"
  alarm_name_prefix   = "NCFXALARMS"
  current_environment = "production"
  template_data = {
    ECS_CLUSTER  = "example"
    ECS_SERVICES = "example"
  }
   alarm_actions = {
    default = {
      alarm = {
        critical = "arn:aws:sns:us-east-1:12345678901:Test-critical"
        info = "arn:aws:sns:us-east-1:12345678901:Test-info"
      }
      ok = {
        critical = "arn:aws:sns:us-east-1:12345678901:Test-critical"
        info = "arn:aws:sns:us-east-1:12345678901:Test-info"
      }
    }
  }
}

