package v1alpha2

// Defines experimental configuration options.
type Experimental struct {
	PilotFeatures `json:"pilot"`

	// Enables dual-stack support.
	// +kubebuilder:validation:Optional
	EnableDualStack *bool `json:"enableDualStack,omitempty"`
}

// Defines experimental configuration options.
type PilotFeatures struct {
	// Enables experimental Gateway API alpha support in Istio Pilot.
	EnableAlphaGatewayAPI                bool `json:"enableAlphaGatewayAPI"`
	// Enables experimental multi-network discovery support in Istio Pilot.
	EnableMultiNetworkDiscoverGatewayAPI bool `json:"enableMultiNetworkDiscoverGatewayAPI"`
}
