resource "aws_autoscaling_group" "this" {
  desired_capacity     = 1
  max_size             = 3
  min_size             = 1
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  target_group_arns = []
  vpc_zone_identifier = [aws_subnet.private_subnet_az1.id]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 30

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
}

resource "aws_autoscaling_schedule" "scale_out_morning" {
  scheduled_action_name  = "scale-out-morning"
  min_size               = 3
  max_size               = 6
  desired_capacity       = 3
  recurrence             = "0 9 * * 1-5" # Cron expression for 09:00 on weekdays
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_schedule" "scale_out_evening" {
  scheduled_action_name  = "scale-out-evening"
  min_size               = 1
  max_size               = 3
  desired_capacity       = 1
  recurrence             = "0 18 * * 1-5" # Cron expression for 18:00 on weekdays
  autoscaling_group_name = aws_autoscaling_group.this.name
}