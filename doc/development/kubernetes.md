# Kubernetes Development Guide

## Development

### Architecture

Some Kubernetes operations, such as creating restricted project
namespaces are performed on the GitLab Rails application. These
operations are performed using a [client library](#client-library).
These operations will carry an element of risk as the operations will be
run as the same user running the GitLab Rails application, see the
[security](#security) section of this doc.

Some Kubernetes operations, such as installing cluster applications are
performed on one-off pods on the Kubernetes cluster itself. These
installation pods are currently named `install-<application_name>`.

We generally add objects that represent Kubernetes resources in
[`lib/gitlab/kubernetes`](https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/gitlab/kubernetes).

### Client library

We use the [`kubeclient`](https://rubygems.org/gems/kubeclient) gem to

perform Kubernetes API calls.
As the `kubeclient` gem does not support different API Groups (e.g.
`apis/rbac.authorization.k8s.io`) from a single client, we have created
a wrapper class,
[`Gitlab::Kubernetes::KubeClient`](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/gitlab/kubernetes/kube_client.rb)
that will enable you to achieve this.

Selected Kubernetes API groups are currently supported. Do add support
for new API groups or methods to
[`Gitlab::Kubernetes::KubeClient`](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/gitlab/kubernetes/kube_client.rb)
if you need to use them.

### Performance considerations

Do try to use background processes when performing Kubernetes API calls.
Do not perform Kubenetes API calls within a web request.

One technique used often is [reactive
caching](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/app/models/concerns/reactive_caching.rb).
For example:

```ruby
  def calculate_reactive_cache!
    { pods: cluster.platform_kubernetes.kubeclient.get_pods }
  end

  def pods
    with_reactive_cache do |data|
      data[:pods]
    end
  end
```

### Testing

We have some Webmock stubs in the
[`KubernetesHelpers`](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/spec/support/helpers/kubernetes_helpers.rb)
helper which can help with mocking out calls to Kubernetes API in your
tests.

## Security

### SSRF

Because all of the URLs for Kubernetes clusters are user controlled it
is easily susceptible to SSRF attacks. You should understand the
mitigation strategies if you are adding more API calls to a cluster.

Mitigation strategies include:

- Not allowing redirects to attacker controller resources.
  `Kubeclient::Client` can be configured to disallow any redirects by
  passing in `http_max_redirects: 0` as an option.
- Not exposing error messages. By not exposing error messages, we
  prevent attackers from triggering errors to expose results from
  attacker controlled requests.

## Debugging

Logs related to the Kubernetes integration can be found in
kubernetes.log](../../administration/logs.md#kuberneteslog). On a local
GDK install, this will be present in `log/kubernetes.log`.

Some services such as
[Clusters::Applications::InstallService](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/app/services/clusters/applications/install_service.rb#L18)
rescues `StandardError` which can make it harder to debug issues in an
development environment. The current workaround is to temporarily
comment out the `rescue` in your local development source.

You can also follow the installation pod logs to debug issues related to
installation. Once the installation/upgrade is underway, wait for the
pod to be created. Then run the following to obtain the pods logs as
they are written:

```bash
kubectl logs <pod_name> --follow -n gitlab-managed-apps
```
