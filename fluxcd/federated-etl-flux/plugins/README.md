# Kubecost Additional Plugins


Plugins extend Kubecost’s functionality, offering more granular insights and enabling advanced management of cloud costs and environmental impact. The available plugins include:
- **Kubecost Actions**
- **Automated Cluster Turndown**
- **Cluster Right-Sizing Recommendations**
- **Container Request Right-Sizing (RRS) Recommendations**
- **Kubescaler (Alpha Mode)**
- **Carbon Costs**


## Enabling the Cluster Controller

To use the following Kubecost Actions:

- **Automated Cluster Turndown**
- **Cluster Right-Sizing Recommendations**
- **Container Request Right-Sizing (RRS) Recommendations**
- **Kubecost Actions**
- **Kubescaler (Alpha Mode)**

you must enable the **Cluster Controller**.

**Note:** Cluster Turndown, Cluster Right-Sizing, and Kubecost Actions are available only on **GKE, EKS, and Kops-on-AWS** clusters after setting up a provider service key. For instructions on how to configure the provider service key, refer to the [Provider Service Key Setup guide](https://docs.kubecost.com/install-and-configure/advanced-configuration/cluster-controller#provider-service-key-setup).



### Automated Cluster Turndown

Cluster Turndown automatically scales down and up the nodes in a Kubernetes cluster based on a custom schedule and turndown criteria, making it ideal for reducing expenses during off-hours or minimizing security exposure. A typical use case includes scaling non-production environments to zero during idle periods.

For detailed configuration and usage instructions, refer to the [Cluster Turndown documentation](https://docs.kubecost.com/install-and-configure/advanced-configuration/cluster-controller/cluster-turndown).



### Cluster Right-Sizing Recommendations

Cluster Right-Sizing Recommendations optimize cluster configurations for cost-efficiency by analyzing resource usage and offering actionable recommendations for right-sizing clusters. Kubecost provides suggestions for cluster-level adjustments, and, with certain configurations, recommendations can be applied directly.

To learn more about using and configuring these recommendations, visit the [Cluster Right-Sizing Recommendations documentation](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations).

*Note:* No Helm configurations are required for this feature. Enabling the Cluster Controller is sufficient to access these recommendations.



### Container Request Right-Sizing (RRS) Recommendations

Container Request Right-Sizing Recommendations optimize resource requests for containers, ensuring accurate resource allocation across the cluster. This feature can help eliminate resource over-allocation and achieve savings through optimized resource distribution.

For more on configuring and adopting these recommendations, see the [Container Request Right-Sizing Recommendations documentation](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations).

*Note:* Similar to Cluster Right-Sizing, only the Cluster Controller needs to be enabled to access this feature—no Helm configurations are necessary.



### Kubecost Actions

The Actions feature in Kubecost enables scheduling and automating cost-saving actions, including cluster turndown, right-sizing, and other savings opportunities. These actions can be configured directly within the primary cluster or via Kubecost’s UI for specific scheduling needs.

For further details and setup instructions, please refer to the [Kubecost Actions documentation](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions).

*Important:* Enabling Kubecost Actions requires the Cluster Controller to be deployed on the primary cluster where all the aggregation happens, granting Kubecost administrative access. Be cautious, as Kubecost will have write access to perform actions.

### Kubescaler (Alpha Mode)

Kubescaler continuously applies Kubecost’s high-fidelity recommendations to resource requests, automatically improving resource allocation efficiency. It can be enabled per workload via annotations and is currently limited to deployment workloads.

For further details and setup instructions, refer to the [Kubescaler documentation](https://docs.kubecost.com/install-and-configure/advanced-configuration/cluster-controller/kubescaler) for more details on how it works and the purpose.

### Carbon Costs

Carbon Costs adds a CO2e metric to the Allocation and Assets dashboards, showing estimated carbon emissions (in KG CO2e) for resources like disk, node, and network assets, based on runtime. This metric uses data from the Cloud Carbon Footprint and is independent of the Cluster Controller.

For more details, refer to the [Carbon Costs documentation](https://docs.kubecost.com/using-kubecost/carbon-costs).


### Plugin Configuration in `helmrelease-plugins.yaml`

To enable all Kubecost plugins—such as Automated Cluster Turndown, Cluster Right-Sizing Recommendations, Container Request Right-Sizing (RRS) Recommendations, Kubescaler, Carbon Costs, and Kubecost Actions—a dedicated `helmrelease-plugins.yaml` template file is provided. This file includes detailed configurations that should be added to your primary cluster’s Helm release. Each plugin’s settings, including those for actions like Cluster Turndown, Namespace Turndown, and Cluster Sizing, are crafted to maximize infrastructure efficiency and manage costs effectively.

Ensure all configurations in `helmrelease-plugins.yaml` are carefully implemented to fully activate these features. This setup allows you to harness Kubecost’s advanced insights and automation capabilities. For additional guidance on configuring each plugin, refer to the respective sections in the file.

