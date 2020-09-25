# opa-experiments


## Running

Run evaluate and output
```
cd practice/k8s/image_tags
opa eval -f pretty -d pod_image_tag.rego -i input.json "data.kubernetes.adminssion.deny"
```