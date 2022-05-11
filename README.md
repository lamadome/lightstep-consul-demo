
# Observability on HCP Consul with Lightstep 
One of the major advantages of consul its 
This repo gives the code to setup the setup observabiliy with Lightstep on HCP Consul
Before we start you will need to create a trial or test account in HCP and Lighstep.
For HCP go to: https://portal.cloud.hashicorp.com/ and create an account
For Lighstep go to: https://lightstep.com/ and create an account

In this tutorial we will also be using the open telemetry colector. You can find more information bellow:
https://opentelemetry.io/docs/collector/
https://github.com/open-telemetry/opentelemetry-collector-contrib

For prometheus we will be using the opentelemetry-prometheus-sidecar from Lightstep:
https://docs.lightstep.com/docs/ingest-metrics-prometheus
https://github.com/lightstep/opentelemetry-prometheus-sidecar

To install the demo environment like the one used in the webinar follow these steps:
## Provision the HCP Cluster
Go to the consul-hcp directory
1) Log on into HCP with your account
2) On the overview page Click on "Deploy with terraform"
3) Click on "Generate Service Principal and Key". Copy the 2 exports generated into your shell and execute:
      export HCP_CLIENT_ID={place your client_id here}
      export HCP_CLIENT_SECRET={place your client_secret here}
(you can ignore the rest of this screen for now)
4) In the repo. Use the variables.auto.tfvars file to specify the region and zone where you want your environment to run. HCP does not run in all zones or regions. Choose one that is closes to you:
https://cloud.hashicorp.com/docs/hcp/supported-env/aws
5) run 'terraform apply'
   This will:
    - Provision a HCP HCN (network)
    - Create a VPC
    - Peer the VPC with the HVN
    - Provision an EKS cluster
    - Install Consul (helm)
6) You will get an output similar to this:
consul_root_token = <sensitive>
consul_url = "<consul public url>"
kubeconfig_filename = "<path to kubeconfig file>"
7) Run the following command terraform 
    ```
    export CONSUL_HTTP_ADDR=$(terraform output consul_url| sed 's~http[s]*://~~g' | sed 's/"//g')
    export CONSUL_HTTP_TOKEN=$(terraform output consul_root_token)
    export CONSUL_HTTP_SSL_VERIFY=false
    ```
### Accessing Consul
9) One terraform has finished deploying go to HCP , Click on View Consul and click on the cluster name starting with 'consul_quickstart'.
10) Go to Access Consul(top right)>Public and click generate admin token. Copy the admin token you will need it to log on to consul
11) Go to Access Consul(top right)>Public and click on the url.  
12) At the top right of the consul UI click on Login and use the token you have copied to log in to consul.
13) Go to services. You will see this screen has only the consul and the ingress service. Later on when we deploy our HashiCups application you will see services being registered here.


## Install Opentelemetry and configure Lighstep
The following few commands are used to enable metrics on the k8s consul client deployed as part of the terraform code
1) Run the following  ``export KUBECONFIG="<path to kubeconfig file>"``
2) Run ```helm get values consul > helmvalus.yaml```  This will save the used helm values to a file. 
3) Now add the metricss stanza the following stanzas:
    a) Under the global :
        ```
        global:
            metrics:
                enabled: true
                enableAgentMetrics: true
                enableGatewayMetrics: true
                agentMetricsRetentionTime: "1m"
        ```
    b) Under connectInject:
        ```
        connectInject:
            default: true
            enabled: true
            transparentProxy:
                defaultEnabled: true
            metrics:
                defaultEnabled: true # by default, this inherits from the value global.metrics.enabled
                defaultEnableMerging: true
        ```
4) Run ``helm upgrade consul hashicorp/consul -f "helmvalues.yaml" ``

Now that we have consul enabled for metrics and telemtry, lets configure the lightstep the open telemetry collector and the lighstep dashboards using terraform.

1) Go to the lighstep-setup folder and rename the variables.auto.tfvars.template file to variables.auto.tfvars
2) Open that file
3) Log in to the lightstep console: https://app.lightstep.com/signin
4) In the left bar go to settings. 
5) At the top copy the organization name and project assign it to the lightstep_org and lightstep_project variables in the tfvars file
6) Click on the copy icon next to the token you see with the same name as your poject and assign it into the LIGHTSTEP_ACCESS_TOKEN variable
7) In the left menu go to account->account settings and click on api keys tab. Click on ``Create new api key```
8) Give a description and make sure to select the member role. Click on ``Create Key``
9) Click on ``Copy and close`` and paste value into the tfvars lightstep_api_key variable. (you will not be able to recover this key later, you can create a new key)
10) Now run ``terraform apply``

Last nut not least, let's deploy the application:
1) go to the k8s-demo-app folder
2) Run ``mv variables.auto.tfvars.hcpquickstart variables.auto.tfvars```
3) Run ``terraform apply``
4) This will install the hashicups application onto k8s.
5) To access the app(hashicups) run the following command to get the url: 
    ```
    echo http://$(kubectl get service/consul-ingress-gateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):$(kubectl get service/consul-ingress-gateway -o jsonpath='{.spec.ports[0].port}')
    ```
6) Go to the lightstep interface and navigate the different elements to watch the metrics coming in.







