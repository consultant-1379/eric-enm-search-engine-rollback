 {{/* vim: set filetype=mustache: */}}

{{/*
The mainImage path (DR-D1121-067)
*/}}
{{- define "eric-enm-search-engine-rollback.mainImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.mainImage.registry -}}
    {{- $repoPath := $productInfo.images.mainImage.repoPath -}}
    {{- $name := $productInfo.images.mainImage.name -}}
    {{- $tag := $productInfo.images.mainImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.mainImage -}}
            {{- if .Values.imageCredentials.mainImage.registry -}}
                {{- if .Values.imageCredentials.mainImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.mainImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.mainImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.mainImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}



{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-enm-search-engine-rollback.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "pullSecret" "eric-enm-search-engine-rollback-secret")) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-search-engine-rollback.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{/* vim: set filetype=mustache: */}}
{{/*
Print the original name of the chart.
*/}}
{{- define "{{.Chart.Name}}.print" -}}
{{- print .Chart.Name -}}
{{- end -}}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-enm-search-engine-rollback.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enm-search-engine-rollback.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enm-search-engine-rollback.pullSecrets" -}}
    {{- $globalPullSecret := "" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.pullSecret -}}
            {{- $globalPullSecret = .Values.global.pullSecret -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.pullSecret -}}
        {{- print .Values.imageCredentials.pullSecret -}}
    {{- else if $globalPullSecret -}}
        {{- print $globalPullSecret -}}
    {{- end -}}
{{- end -}}

{{- define "eric-enm-search-engine-rollback.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.mainImage.registry -}}
        {{- if .Values.imageCredentials.mainImage.registry.imagePullPolicy -}}
        {{- $globalRegistryPullPolicy = .Values.imageCredentials.mainImage.registry.imagePullPolicy -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}


{{/*
Create annotation for the product information (DR-D1121-064, DR-D1121-067)
*/}}
{{- define "eric-enm-search-engine-rollback.product-info" }}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create a user defined annotation (DR-D1121-065, DR-D1121-060)
*/}}
{{ define "eric-enm-search-engine-rollback.config-annotations" }}
  {{- $global := (.Values.global).annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-enm-search-engine-rollback.mergeAnnotations" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged annotations for Default, which includes productInfo and config
*/}}
{{- define "eric-enm-search-engine-rollback.annotations" -}}
  {{- $productInfo := include "eric-enm-search-engine-rollback.product-info" . | fromYaml -}}
  {{- $config := include "eric-enm-search-engine-rollback.config-annotations" . | fromYaml -}}
  {{- include "eric-enm-search-engine-rollback.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $config)) | trim }}
{{- end -}}

{{/*
Standard labels of Helm and Kubernetes
*/}}
{{- define "eric-enm-search-engine-rollback.standard-labels" -}}
app.kubernetes.io/name: {{ include "eric-enm-search-engine-rollback.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "eric-enm-search-engine-rollback.version" . }}
helm.sh/chart: {{ include "eric-enm-search-engine-rollback.chart" . }}
chart: {{ include "eric-enm-search-engine-rollback.chart" . }}
{{- end -}}

{{/*
Create a user defined label (DR-D1121-068, DR-D1121-060)
*/}}
{{ define "eric-enm-search-engine-rollback.config-labels" }}
  {{- $global := (.Values.global).labels -}}
  {{- $service := .Values.labels -}}
  {{- include "eric-enm-search-engine-rollback.mergeLabels" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-enm-search-engine-rollback.labels" -}}
  {{- $standard := include "eric-enm-search-engine-rollback.standard-labels" . | fromYaml -}}
  {{- $config := include "eric-enm-search-engine-rollback.config-labels" . | fromYaml -}}
  {{- include "eric-enm-search-engine-rollback.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-enm-search-engine-rollback.nodeSelector" }}
  {{- $g := fromJson (include "eric-enm-search-engine-rollback.global" .) -}}
  {{- $global := $g.nodeSelector -}}
  {{- $service := .Values.nodeSelector -}}
  {{- include "eric-enm-search-engine-rollback.aggregatedMerge" (dict "context" "nodeSelector" "location" .Template.Name "sources" (list $global $service)) }}
{{ end }}


{{/*
Volume mount name used for Statefulset
*/}}
{{- define "eric-enm-search-engine-rollback.persistence.volumeMount.name" -}}
  {{- printf "%s" "example-data" -}}
{{- end -}}

{{/*
adding TopologySpreadConstraints
*/}}
{{- define "eric-enm-search-engine-rollback.topologySpreadConstraints" }}
{{- if .Values.topologySpreadConstraints }}
{{- range $config, $values := .Values.topologySpreadConstraints }}
- topologyKey: {{ $values.topologyKey }}
  maxSkew: {{ $values.maxSkew | default 1 }}
  whenUnsatisfiable: {{ $values.whenUnsatisfiable | default "ScheduleAnyway" }}
  labelSelector:
    matchLabels:
      app: {{ template "eric-enm-search-engine-rollback.name" $ }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create annotations for roleBinding.
*/}}
{{- define "eric-enm-search-engine-rollback.securityPolicy.annotations" }}
ericsson.com/security-policy.type: "restricted/default"
ericsson.com/security-policy.privileged: "false"
ericsson.com/security-policy.capabilities: "N/A"
{{- end -}}
{{/*
Create roleBinding reference.
*/}}
{{- define "eric-enm-search-engine-rollback.securityPolicy.reference" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.security -}}
            {{- if .Values.global.security.policyReferenceMap -}}
              {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
              {{- if $mapped -}}
                {{ $mapped }}
              {{- else -}}
                {{ $mapped }}
              {{- end -}}
            {{- else -}}
              default-restricted-security-policy
            {{- end -}}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
{{- end -}}
