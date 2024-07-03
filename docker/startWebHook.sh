# https://blog.csdn.net/ljx1528/article/details/120070330
# webHook
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

# 钉钉模板
cat >> ${localPath}/config/dingding.tmpl << EOF
{{ define "__subject" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }} {{ if gt (len .CommonLabels) (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{ .Values | join " " }}{{ end }}){{ end }}{{ end }}
{{ define "__alertmanagerURL" }}{{ .ExternalURL }}/#/alerts?receiver={{ .Receiver }}{{ end }}

{{ define "__text_alert_list" }}{{ range . }}
告警程序：prometheus_alert
告警级别：{{ .Labels.severity }}
告警类型：{{ .Labels.alertname }}
主机: {{ .Labels.instance }}
命名空间: {{ .Labels.namespace }}
Pod: {{ .Labels.pod }}
告警主题: {{ .Annotations.summary }}
告警描叙: {{ .Annotations.description }}
触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }}
------------------------

{{ end }}{{ end }}

{{ define "__text_resolve_list" }}{{ range .  }}
恢复程序：{{ .Labels.alertname }}
主机: {{ .Labels.instance }}
恢复描叙: {{ .Annotations.description }}
触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }}
------------------------
{{ end }}{{ end }}


{{ define "ding.link.title" }}{{ template "__subject" . }}{{ end }}
{{ define "ding.link.content" }}#### \[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}\] **[{{ index .GroupLabels "alertname" }}]({{ template "__alertmanagerURL" . }})**
{{ if gt (len .Alerts.Firing) 0 -}}
![警报 图标](https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3626076420,1196179712&fm=15&gp=0.jpg)

**====侦测到故障====**

{{ template "__text_alert_list" .Alerts.Firing }}
{{- end }}
{{ if gt (len .Alerts.Resolved) 0 -}}
恢复列表:
{{ template "__text_resolve_list" .Alerts.Resolved }}
{{- end }}
{{- end }}
EOF

# 拉去镜像
# docker pull timonwong/prometheus-webhook-dingtalk:v0.3.0

docker run -d --restart always -p 8060:8060 --name webhook-dingding -v ${localPath}/config/dingding.tmpl:/root/dingding.tmpl -v /etc/localtime:/etc/localtime timonwong/prometheus-webhook-dingtalk:v0.3.0 --template.file="/root/dingding.tmpl" --ding.profile="webhook1=https://oapi.dingtalk.com/robot/send?access_token=78d3c87136091eff724dd5379ba96ca4a1c1217b91a7f98303c189aa1980b0d1"