# Istio Custom Resource

The `istios.operator.kyma-project.io` CustomResourceDefinition (CRD) describes the kind and the format of data that Istio Controller uses to configure,
update, and manage the Istio installation. Applying the CR triggers the installation of Istio,
and deleting it triggers the uninstallation of Istio. The default Istio CR has the name `default`.

To get the up-to-date CRD in the `yaml` format, run the following command:

```shell
kubectl get crd istios.operator.kyma-project.io -o yaml
```
You are only allowed to use one Istio CR, which you must create in the `kyma-system` namespace.
If the namespace contains multiple Istio CRs, the oldest one reconciles the module.
Any additional Istio CR is placed in the `Warning` state.

## Sample Custom Resource
This is a sample Istio CR that that configures Istio installation in your Kyma cluster.

```yaml
{TBD}
```

## Custom Resource Parameters
The following tables list all the possible parameters of a given resource together with their descriptions.

### APIVersions
- [operator.kyma-project.io/v1alpha2](#operatorkyma-projectiov1alpha2)

### Resource Types
- [Istio](#istio)

### Authorizer

Defines an external authorization provider's configuration.
The defined authorizer can be referenced by name in an AuthorizationPolicy
with action CUSTOM to enforce requests to be authorized by the external authorization service.

Appears in:
- [Config](#config)

| Field | Description | Validation |
| --- | --- | --- |
| **name** <br /> string | A unique name identifying the authorization provider. | Required <br /> |
| **service** <br /> string | Specifies the service that implements the Envoy `ext_authz` HTTP authorization service.<br />The recommended format is `[Namespace/]Hostname`.<br />Specifying the namespace is necessary only if it is required to unambiguously resolve a service in the service registry.<br />The host name refers to the fully qualified host name of a service defined by either a Kubernetes Service or a ServiceEntry. | None |
| **port** <br /> integer | Specifies the port of the Service. | Required <br /> |
| **headers** <br /> [Headers](#headers) | Specifies headers included, added, or forwarded during authorization. | None |
| **pathPrefix** <br /> string | Specifies the prefix which included in the request sent to the authorization service.<br />The prefix might be constructed with special characters (e.g., `/test?original_path=`). | Optional <br /> |
| **timeout** <br /> [Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta) | Specifies the timeout for the HTTP authorization request to the external service. | Optional <br /> |

### CniComponent

Configures the CNI Istio component.

Appears in:
- [Components](#components)

| Field | Description | Validation |
| --- | --- | --- |
| **k8s** <br /> [CniK8sConfig](#cnik8sconfig) | **CniK8sConfig** is a subset of [KubernetesResourcesSpec](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#KubernetesResourcesSpec). | Required <br /> |

### CniK8sConfig

Appears in:
- [CniComponent](#cnicomponent)

| Field | Description | Validation |
| --- | --- | --- |
| **affinity** <br /> [Affinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#affinity-v1-core) | Defines the Pod scheduling affinity constraints. See [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity). | Optional <br /> |
| **resources** <br /> [Resources](#resources) | Defines Kubernetes resources' configuration. See [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). | Optional <br /> |

### Components

Appears in:
- [IstioSpec](#istiospec)

| Field | Description | Validation |
| --- | --- | --- |
| **pilot** <br /> [IstioComponent](#istiocomponent) | Defines component configuration for Istiod. | None |
| **ingressGateway** <br /> [IstioComponent](#istiocomponent) | Defines component configurations for Istio Ingress Gateway. | None |
| **cni** <br /> [CniComponent](#cnicomponent) | Defines component configuration for Istio CNI DaemonSet. | None |
| **proxy** <br /> [ProxyComponent](#proxycomponent) | Defines component configuration for the Istio sidecar proxy. | None |
| **egressGateway** <br /> [EgressGateway](#egressgateway) | Defines component configuration for Istio Egress Gateway. | Optional <br /> |

### ConditionReason

Underlying type: string

Appears in:
- [ReasonWithMessage](#reasonwithmessage)
 
| Field | Description |
| --- | --- |
| **ReconcileSucceeded** | Reconciliation finished successfully.<br /> |
| **ReconcileUnknown** | Reconciliation is in progress or failed previously.<br /> |
| **ReconcileRequeued** | Reconciliation is requeued to be tried again later.<br /> |
| **ReconcileFailed** | Reconciliation failed.<br /> |
| **ValidationFailed** | Reconciliation did not happen as validation of Istio Custom Resource failed.<br /> |
| **OlderCRExists** | Reconciliation did not happen because an older Istio CR exists.<br /> |
| **OldestCRNotFound** | Reconciliation did not happen as the oldest Istio Custom Resource could not be found.<br /> |
| **IstioInstallNotNeeded** | Istio installation is not needed.<br /> |
| **IstioInstallSucceeded** | Istio installation or uninstallation succeeded.<br /> |
| **IstioUninstallSucceeded** | Istio uninstallation succeeded.<br /> |
| **IstioInstallUninstallFailed** | Istio installation or uninstallation failed.<br /> |
| **IstioCustomResourceMisconfigured** | The Istio custom resource has invalid configuration.<br /> |
| **IstioCustomResourcesDangling** | Istio custom resources are blocking Istio uninstallation.<br /> |
| **IstioVersionUpdateNotAllowed** | Istio version update is not allowed.<br /> |
| **CustomResourcesReconcileSucceeded** | Reconciliation of custom resources succeeded.<br /> |
| **CustomResourcesReconcileFailed** | Reconciliation of custom resources failed.<br /> |
| **ProxySidecarRestartSucceeded** | Proxy sidecar restart succeeded.<br /> |
| **ProxySidecarRestartFailed** | Proxy sidecar restart failed.<br /> |
| **ProxySidecarRestartPartiallySucceeded** | Proxy sidecar restart partially succeeded. //TODO what this means?<br /> |
| **ProxySidecarManualRestartRequired** | A manual restart of the proxy sidecar is required for some workloads..<br /> |
| **IngressGatewayRestartSucceeded** | Istio ingress gateway restart succeeded.<br /> |
| **IngressGatewayRestartFailed** | Istio ingress gateway restart failed.<br /> |
| **EgressGatewayRestartSucceeded** | Istio egress gateway restart succeeded.<br /> |
| **EgressGatewayRestartFailed** | Istio egress gateway restart failed.<br /> |
| **IngressTargetingUserResourceFound** | Resource targeting Istio Ingress Gateway found.<br /> |
| **IngressTargetingUserResourceNotFound** | No resources targeting Istio Ingress Gateway found.<br /> |
| **IngressTargetingUserResourceDetectionFailed** | Resource targeting Istio Ingress Gateway detection failed.<br /> |


### Config

Specifies the configuration for the Istio installation.

Appears in:
- [IstioSpec](#istiospec)

| Field | Description | Validation |
| --- | --- | --- |
| **numTrustedProxies** <br /> integer | Defines the number of trusted proxies deployed in front of the Istio gateway proxy. | Maximum: 4.294967295e+09 <br />Minimum: 0 <br /> |
| **authorizers** <br /> [Authorizer](#authorizer) array | Defines a list of external authorization providers. | None |
| **gatewayExternalTrafficPolicy** <br /> string | Defines the external traffic policy for the Istio Ingress Gateway Service. Valid configurations are `"Local"` or `"Cluster"`. The external traffic policy set to `"Local"` preserves the client IP in the request, but also introduces the risk of unbalanced traffic distribution.<br />> [!WARNING]: Switching `externalTrafficPolicy` may result in a temporal increase in request delay. Make sure that this is acceptable. | Enum: [Local Cluster] <br />Optional <br /> |
| **telemetry** <br /> [Telemetry](#telemetry) | Defines the telemetry configuration of Istio. | Optional <br /> |

### EgressGateway

Configures the Istio Egress Gateway.

Appears in:
- [Components](#components)

| Field | Description | Validation |
| --- | --- | --- |
| **k8s** <br /> [KubernetesResourcesConfig](#kubernetesresourcesconfig) | Defines the Kubernetes resources' configuration for Istio Egress Gateway. | Optional <br /> |
| **enabled** <br /> boolean | Enables or disables Istio Egress Gateway. | Optional <br /> |

### Experimental

Appears in:
- [IstioSpec](#istiospec)

| Field | Description | Validation |
| --- | --- | --- |
| **pilot** <br /> [PilotFeatures](#pilotfeatures) |  | None |
| **enableDualStack** <br /> boolean | Enables the Dual Stack support | Optional <br /> |

### HPASpec

Defines configuration for HorizontalPodAutoscaler.

Appears in:
- [KubernetesResourcesConfig](#kubernetesresourcesconfig)

| Field | Description | Validation |
| --- | --- | --- |
| **maxReplicas** <br /> integer | Defines the minimum number of replicas for the HorizontalPodAutoscaler. | Maximum: 2.147483647e+09 <br />Minimum: 0 <br /> |
| **minReplicas** <br /> integer | Defines the maximum number of replicas for the HorizontalPodAutoscaler. | Maximum: 2.147483647e+09 <br />Minimum: 0 <br /> |

### Headers

Appears in:
- [Authorizer](#authorizer)

| Field | Description | Validation |
| --- | --- | --- |
| **inCheck** <br /> [InCheck](#incheck) | Defines headers to be included or added in check authorization request. | None |
| **toUpstream** <br /> [ToUpstream](#toupstream) | Defines headers to be forwarded to the upstream (to the backend service). | None |
| **toDownstream** <br /> [ToDownstream](#todownstream) | Defines headers to be forwarded to the downstream (the client). | None |

### InCheck

Appears in:
- [Headers](#headers)

| Field | Description | Validation |
| --- | --- | --- |
| **include** <br /> string array | Lists client request headers included in the authorization request sent to the authorization service.<br />In addition to the headers specified here, the following headers are included by default:<br />- *Host*, *Method*, *Path*, and *Content-Length* are automatically sent.<br />- *Content-Length* is set to `0`, and the request does have a message body. However, the authorization request can include the buffered client request body (controlled by the **include_request_body_in_check** setting), consequently the **Content-Length** value of the authorization request reflects its payload size. | None |
| **add** <br /> object (keys:string, values:string) | Specifies a set of additional fixed headers that included in the authorization request sent to the authorization service.<br />The key is the header name and value is the header value.<br />Client request of the same key or headers specified in `Include` are overridden. | None |

### Istio

Contains the Istio custom resource's specification and its current status.

| Field | Description | Validation |
| --- | --- | --- |
| **apiVersion** <br /> string | `operator.kyma-project.io/v1alpha2` | None |
| **kind** <br /> string | `Istio` | None |
| **metadata** <br /> [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta) | For more information on the metadata fields, see Kubernetes API documentation. | None |
| **spec** <br /> [IstioSpec](#istiospec) | Defines the desired state of the Istio installation. | None |
| **status** <br /> [IstioStatus](#istiostatus) | Represents the current state of the Istio installation. | None |

### IstioComponent

IstioComponent defines the configuration for the generic Istio components, that is, Istio Ingress gateway and istiod.

Appears in:
- [Components](#components)

| Field | Description | Validation |
| --- | --- | --- |
| **k8s** <br /> [KubernetesResourcesConfig](#kubernetesresourcesconfig) |  | Required <br /> |

### IstioSpec

IstioSpec describes the desired specification for installing or updating Istio.

Appears in:
- [Istio](#istio)

| Field | Description | Validation |
| --- | --- | --- |
| **config** <br /> [Config](#config) | Defines configuration of the Istio installation. | Optional <br /> |
| **components** <br /> [Components](#components) | Defines Istio components's configuration. | Optional <br /> |
| **experimental** <br /> [Experimental](#experimental) | Defines experimental configuration options. | Optional <br /> |
| **compatibilityMode** <br /> boolean | Enables compatibility mode for Istio installation. | Optional <br /> |

### IstioStatus

IstioStatus defines the observed state of IstioCR.

Appears in:
- [Istio](#istio)

| Field | Description | Validation |
| --- | --- | --- |
| **state** <br /> [State](#state) | State signifies the current state of CustomObject. Value<br />can be one of ("Ready", "Processing", "Error", "Deleting", "Warning"). | Enum: [Processing Deleting Ready Error Warning] <br />Required <br /> |
| **conditions** <br /> [Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#condition-v1-meta) |  Conditions associated with IstioStatus. | None |
| **description** <br /> string | Description of Istio status. | None |

### KubernetesResourcesConfig

**KubernetesResourcesConfig** is a subset of [KubernetesResourcesSpec](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#KubernetesResourcesSpec).

Appears in:
- [EgressGateway](#egressgateway)
- [IstioComponent](#istiocomponent)

| Field | Description | Validation |
| --- | --- | --- |
| **hpaSpec** <br /> [HPASpec](#hpaspec) | Defines configuration for [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). | Optional <br /> |
| **strategy** <br /> [Strategy](#strategy) | Defines configuration for rolling updates. See [Rolling Update Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment). | Optional <br /> |
| **resources** <br /> [Resources](#resources) | Defines Kubernetes resources' configuration. See [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). | Optional <br /> |

### Metrics

Appears in:
- [Telemetry](#telemetry)

| Field | Description | Validation |
| --- | --- | --- |
| **prometheusMerge** <br /> boolean | Defines whether the prometheusMerge feature is enabled. If yes, appropriate prometheus.io annotations are added to all data plane Pods to set up scraping.<br />If these annotations already exist, they are overwritten. With this option, the Envoy sidecar merges Istio’s metrics with the application metrics.<br />The merged metrics are scraped from `:15020/stats/prometheus`. | Optional <br /> |

### PilotFeatures

Appears in:
- [Experimental](#experimental)

| Field | Description | Validation |
| --- | --- | --- |
| **enableAlphaGatewayAPI** <br /> boolean |  | None |
| **enableMultiNetworkDiscoverGatewayAPI** <br /> boolean |  | None |

### ProxyComponent

Defines Istio proxies' configuration.

Appears in:
- [Components](#components)

| Field | Description | Validation |
| --- | --- | --- |
| **k8s** <br /> [ProxyK8sConfig](#proxyk8sconfig) | ProxyK8sConfig is a subset of [KubernetesResourcesSpec](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#KubernetesResourcesSpec). | Required <br /> |

### ProxyK8sConfig

**ProxyK8sConfig** is a subset of [KubernetesResourcesSpec](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#KubernetesResourcesSpec).

Appears in:
- [ProxyComponent](#proxycomponent)

| Field | Description | Validation |
| --- | --- | --- |
| **resources** <br /> [Resources](#resources) |  | None |


### ResourceClaims

Defines CPU and memory resource requirements for Kubernetes containers and Pods. See [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

Appears in:
- [Resources](#resources)

| Field | Description | Validation |
| --- | --- | --- |
| **cpu** <br /> string | Specifies CPU resource allocation (requests or limits) | Pattern: `^([0-9]+m?\|[0-9]\.[0-9]\{1,3\})$` <br /> |
| **memory** <br /> string | Specifies memory resource allocation (requests or limits). | Pattern: `^[0-9]+(((\.[0-9]+)?(E\|P\|T\|G\|M\|k\|Ei\|Pi\|Ti\|Gi\|Mi\|Ki\|m)?)\|(e[0-9]+))$` <br /> |

### Resources

Defines Kubernetes resources' configuration. See [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

Appears in:
- [CniK8sConfig](#cnik8sconfig)
- [KubernetesResourcesConfig](#kubernetesresourcesconfig)
- [ProxyK8sConfig](#proxyk8sconfig)

| Field | Description | Validation |
| --- | --- | --- |
| **limits** <br /> [ResourceClaims](#resourceclaims) | The maximum amount of resources a container is allowed to use. | None |
| **requests** <br /> [ResourceClaims](#resourceclaims) | The minimum amount of resources ( such as CPU and memory) a container needs to run. | None |

### RollingUpdate

Defines the configuration for rolling updates. See [Rolling Update Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment).

Appears in:
- [Strategy](#strategy)

| Field | Description | Validation |
| --- | --- | --- |
| **maxSurge** <br /> [IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#intorstring-intstr-util) | Specifies the maximum number of Pods that can be unavailable during the update process. See [Max Surge](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#max-surge). | Pattern: `^[0-9]+%?$` <br />XIntOrString: \{\} <br /> |
| **maxUnavailable** <br /> [IntOrString](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#intorstring-intstr-util) | Specifies the maximum number of Pods that can be created over the desired number of Pods. See [Max Unavailable](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#max-unavailable) | Pattern: `^((100\|[0-9]\{1,2\})%\|[0-9]+)$` <br />XIntOrString: \{\} <br /> |

### State

Underlying type: string

Appears in:
- [IstioStatus](#istiostatus)
 
| Field | Description |
| --- | --- |
| **Ready** | Istio installation or upgrade process has completed successfully.<br /> |
| **Processing** | Istio installation or upgrade process is in progress.<br /> |
| **Error** | Istio installation or upgrade process has failed.<br /> |
| **Deleting** | The Istio custom resource is being deleted.<br /> |
| **Warning** | Istio installation or upgrade process has completed with warnings.<br />This state warrants user attention, as some features may not work as expected.<br /> |

### Strategy

Appears in:
- [KubernetesResourcesConfig](#kubernetesresourcesconfig)

| Field | Description | Validation |
| --- | --- | --- |
| **rollingUpdate** <br /> [RollingUpdate](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#rollingupdatedeployment-v1-apps) | Defines the rolling update strategy. | Required <br /> |

### Telemetry

Appears in:
- [Config](#config)

| Field | Description | Validation |
| --- | --- | --- |
| **metrics** <br /> [Metrics](#metrics) | Specifies the configuration of Istio telemetry metrics. | Optional <br /> |

### ToDownstream

Appears in:
- [Headers](#headers)

| Field | Description | Validation |
| --- | --- | --- |
| **onAllow** <br /> string array | Lists headers from the authorization service forwarded to downstream when the authorization check result is allowed (HTTP code `200`).<br />If not specified, the original request is forwarded to the backend unmodified.<br />Any existing headers are overridden. | None |
| **onDeny** <br /> string array | Lists headers from the authorization service forwarded to downstream when the authorization check result is not allowed (HTTP code is other than `200`).<br />If not specified, all the authorization response headers, except *Authority (Host)*, are included in the response to the downstream.<br />When a header is included in this list, the following headers are automatically added: *Path*, *Status*, *Content-Length*, *WWWAuthenticate*, and *Location*.<br />The body from the authorization service is always included in the response to downstream. | None |

### ToUpstream

Appears in:
- [Headers](#headers)

| Field | Description | Validation |
| --- | --- | --- |
| **onAllow** <br /> string array | Lists headers from the authorization service added or overridden in the original request and forwarded to the upstream when the authorization check result is allowed (HTTP code `200`).<br />If not specified, the original request is forwarded to the backend unmodified.<br />Any existing headers are overridden. | None |

