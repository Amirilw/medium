#!/bin/bash
set -e
clsuters="Cluster_A Cluster_B Cluster_C Cluster_D"
get_date=$(date +"%Y-%m-%d-%H-%M")
echo $get_date
mkdir -p ~/k8s_backup_files/$get_date
kubernetes_object_types="pods deployments statefulsets pvc"
kubernetes_cluster_object_types="pv"
for cluster in $clsuters;do
# get namespaces
    mkdir -p ~/k8s_backup_files/$get_date/$cluster
    namespaces=$(kubectl --context $cluster get namespaces | grep -v 'NAME'| awk '{print$1}')
    for namespace in $namespaces;do
    #per namespace actions
        mkdir -p ~/k8s_backup_files/$get_date/$cluster/$namespace
        for kubernetes_object_type in $kubernetes_object_types;do
            mkdir -p ~/k8s_backup_files/$get_date/$cluster/$namespace/$kubernetes_object_type
            kubernetes_objects=$(kubectl --context $cluster --namespace $namespace get $kubernetes_object_type | grep -v 'NAME'| awk '{print$1}')
            for kubernetes_object in $kubernetes_objects;do
                kubectl --context $cluster --namespace $namespace get $kubernetes_object_type $kubernetes_object --output yaml > ~/k8s_backup_files/$get_date/"$cluster"/"$namespace"/"$kubernetes_object_type"/"$kubernetes_object".yaml
                echo ""$cluster"_"$namespace"_"$kubernetes_object_type"_"$kubernetes_object".yaml"
            done
        done
    done
    #cluster wide objects (not namespaced)
    for kubernetes_cluster_object_type in $kubernetes_cluster_object_types;do
        mkdir -p ~/k8s_backup_files/$get_date/$cluster/$kubernetes_cluster_object_type
        kubernetes_cluster_objects=$(kubectl --context $cluster  get $kubernetes_cluster_object_type | grep -v 'NAME'| awk '{print$1}')
        for kubernetes_cluster_object in $kubernetes_cluster_objects;do
            kubectl --context $cluster  get $kubernetes_cluster_object_type $kubernetes_cluster_object --output yaml > ~/k8s_backup_files/$get_date/"$cluster"/"$kubernetes_cluster_object_type"/"$kubernetes_cluster_object".yaml
            echo ""$cluster"_"$namespace"_"$kubernetes_cluster_object_type"_"$kubernetes_cluster_object".yaml"
        done
    done
done         
