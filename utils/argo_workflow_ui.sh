#!/bin/bash

echo "Port forwarding Argo Workflow UI: https://localhost:2746/"
kubectl port-forward deployment/argo-server -n argo 2746:2746 > /dev/null &
open https://localhost:2746/
