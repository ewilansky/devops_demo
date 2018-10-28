#!/usr/bin/env bash
kubectl delete rs --all
kubectl delete deployments --all
kubectl delete services --all
kubectl delete pods --all