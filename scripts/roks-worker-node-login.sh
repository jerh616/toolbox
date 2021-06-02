#!/bin/sh
# k get nodes to get the IPs and use the IP of the node you want. Make sure you are on the correct cluster!

set -x
node=${1}
nodeName=$(kubectl get node ${node} -o template --template='{{index .metadata.labels "kubernetes.io/hostname"}}') 
nodeSelector='"nodeSelector": { "kubernetes.io/hostname": "'${nodeName:?}'" },'
podName=${USER}-nsenter-${node}
kubectl run ${podName:?} --restart=Never -it --rm --image overriden --overrides '
{
  "spec": {
    "hostPID": true,
    "hostNetwork": true,
    '"${nodeSelector?}"'
    "tolerations": [{
        "operator": "Exists"
    }],
    "containers": [
      {
        "name": "nsenter",
        "image": "alexeiled/nsenter:2.34",
"command": ["/nsenter", "-t", "1", "-m", "-u", "-i", "-n", "-p", "--", "/bin/bash" ],        
"stdin": true,
        "tty": true,
        "securityContext": {
          "privileged": true
        }
      }
    ]
  }
}' --attach "$@"
