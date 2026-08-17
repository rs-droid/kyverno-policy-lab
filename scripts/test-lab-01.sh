#!/usr/bin/env bash

set -euo pipefail

POLICY="policies/validate/disallow-privileged-containers.yaml"
NONCOMPLIANT="manifests/workloads/noncompliant/privileged-pod.yaml"
COMPLIANT="manifests/workloads/compliant/restricted-pod.yaml"

echo "=== Lab 01: Privileged Container Validation ==="
echo

echo "[1/4] Checking Kubernetes connectivity..."
kubectl cluster-info >/dev/null
echo "PASS: Kubernetes API is reachable."
echo

echo "[2/4] Applying Kyverno policy..."
kubectl apply -f "$POLICY"
echo "PASS: Policy applied."
echo

echo "[3/4] Testing noncompliant workload..."

if kubectl apply -f "$NONCOMPLIANT"; then
    echo "FAIL: Privileged Pod was admitted."
    kubectl delete pod privileged-pod --ignore-not-found
    exit 1
else
    echo "PASS: Privileged Pod was rejected."
fi

echo

echo "[4/4] Testing compliant workload..."

if kubectl apply -f "$COMPLIANT"; then
    echo "PASS: Compliant Pod was admitted."
else
    echo "FAIL: Compliant Pod was rejected."
    exit 1
fi

echo
echo "Cleaning up..."
kubectl delete pod restricted-pod --ignore-not-found
kubectl delete -f "$POLICY" --ignore-not-found

echo
echo "=== Lab 01 PASSED ==="
