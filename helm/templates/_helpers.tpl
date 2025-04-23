{{/*
Expand the name of the chart.
*/}}
{{- define "my-app.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
