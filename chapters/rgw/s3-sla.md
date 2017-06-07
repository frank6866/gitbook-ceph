# S3的SLA规则

官网介绍: [https://aws.amazon.com/cn/s3/sla/](https://aws.amazon.com/cn/s3/sla/)




## 相关概念
* 错误率: S3每隔5分钟就会计算一次错误率，计算公式为，错误率=5xx响应数(5分钟内)/总响应数(5分钟内)
* 每月服务可用率(monthly\_uptime\_percentage): 每个月的错误率(monthly\_error\_percentage)为该月每5分钟错误率的平均值，monthly\_uptime\_percentage =100%-monthly\_error\_percentage



## 补偿

* 如果monthly\_uptime\_percentage>=99.9%，服务正常
* 如果99.0%<=monthly\_uptime\_percentage<99.9%，赔偿一个月账单的10%
* 如果monthly\_uptime\_percentage<99.0%，赔偿一个月账单的25%



