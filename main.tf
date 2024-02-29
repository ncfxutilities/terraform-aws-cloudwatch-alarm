# CloudWatch Alarms
module "metric-alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.0"
  for_each = { for i in flatten([
    for Key, Value in local.CloudWatch["Cloudwatch"] : [
      for loopK, loopV in try(var.loop[Value.Loop], ["default"]) : {
        ServiceKey = loopV
        Name       = Value.Name
        Key        = Key
        Config     = Value
      }
    ]
    ]) : "${i.Name}-${i.ServiceKey}" => i
  if contains(i.Config.Environment, var.current_environment) || !can(i.Config.Environment) }
  alarm_name          = "${var.alarm_name_prefix}-${each.key}"
  alarm_description   = each.value.Config.Description
  comparison_operator = each.value.Config.Operator
  evaluation_periods  = each.value.Config.EvaluationPeriods
  threshold           = each.value.Config.Threshold

  treat_missing_data = each.value.Config.TreatMissingData

  namespace   = can(each.value.Config.Query) ? null : each.value.Config.Namespace
  metric_name = can(each.value.Config.Query) ? null : each.value.Config.Metrics
  statistic   = can(each.value.Config.Query) ? null : each.value.Config.Statistic
  dimensions  = can(each.value.Config.Query) ? null : try({ for dK, dV in try(each.value.Config.Dimensions, {}) : dV.Name => dV.Value }, {})
  period      = can(each.value.Config.Query) ? null : each.value.Config.Period
  metric_query = can(each.value.Config.Query) ? [for qK, qV in each.value.Config.Query : {
    # id          = (can(qV.expression)) ? "e${qK}" : "m${qK}"
    id          = qV.id
    label       = can(qV.label) ? qV.label : null
    return_data = try(qV.return_data, false)
    expression  = try(qV.expression, null)
    period      = try(qV.period, null)

    metric = can(qV.metric) ? [
      for metric_item in qV.metric : {
        namespace   = try(metric_item.namespace, "")
        metric_name = try(metric_item.metric_name, "")
        period      = try(metric_item.period, null)
        stat        = try(metric_item.stat, "")
        unit        = try(metric_item.unit, null)
        dimensions  = try(metric_item.dimensions, {})
        # { for dK, dV in try(metric_item.dimensions, {}) : dK => dV }
        #{ for dK, dV in try(metric_item.metric.dimensions, []) : dK => dV }
      }
    ] : []

  }] : []


  actions_enabled = can(each.value.Config.AlarmActions) ? true : false
  alarm_actions = [for aK, aV in each.value.Config.AlarmActions.ALARM :
    try(var.alarm_actions[aK]["alarm"][aV[var.current_environment]], "")
    if can(var.alarm_actions[aK]["alarm"][aV[var.current_environment]])
  ]
  ok_actions = [for aK, aV in each.value.Config.AlarmActions.OK :
    try(var.alarm_actions[aK]["ok"][aV[var.current_environment]], "")
    if can(var.alarm_actions[aK]["ok"][aV[var.current_environment]])
  ]
}

#CloudWatch Custom Metrics
module "log-metric-filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 4.0"
  for_each = { for i in flatten([
    for Key, Value in local.CloudWatch["Cloudwatch"] : [
      for loopK, loopV in try(var.loop[Value.Loop], ["default"]) : {
        ServiceKey = loopV
        Name       = Value.Name
        Key        = Key
        Config     = Value
      }
    ]
    ]) : "${i.Name}-${i.ServiceKey}" => i
  if(contains(i.Config.Environment, var.current_environment) || !can(i.Config.Environment)) && can(i.Config.CustomMetrics) }

  log_group_name = each.value.Config.CustomMetrics.LogGroupName

  name    = "${each.key}-${each.value.Config.Metrics}-metricfilter"
  pattern = each.value.Config.CustomMetrics.Pattern

  metric_transformation_namespace = each.value.Config.Namespace
  metric_transformation_name      = each.value.Config.Metrics
}
