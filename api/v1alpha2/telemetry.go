package v1alpha2

type Telemetry struct {
	// Specifies the configuration of Istio telemetry metrics.
	// +kubebuilder:validation:Optional
	Metrics Metrics `json:"metrics,omitempty"`
}

type Metrics struct {
	// Defines whether the prometheusMerge feature is enabled. If yes, appropriate prometheus.io annotations are added to all data plane Pods to set up scraping.
	// If these annotations already exist, they are overwritten. With this option, the Envoy sidecar merges Istio’s metrics with the application metrics.
	// The merged metrics are scraped from `:15020/stats/prometheus`.
	// +kubebuilder:validation:Optional
	PrometheusMerge bool `json:"prometheusMerge,omitempty"`
}
