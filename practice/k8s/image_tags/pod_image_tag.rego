# Hello World
# -----------
#
# This example ensures that every resource that specifies a 'costcenter' label does
# so in the appropriate format. This example shows how to:
#
#	* Define rules that generate sets of error messages (e.g., `deny` below.)
#	* Refer to the data sent by Kubernetes in the Admission Review request.
#
# For additional information, see:
#
#	* Rego Rules: https://www.openpolicyagent.org/docs/latest/#rules
#	* Rego References: https://www.openpolicyagent.org/docs/latest/#references
#	* Kubernetes Admission Reviews: https://www.openpolicyagent.org/docs/latest/kubernetes-primer/#input-document

package kubernetes.adminssion

# `deny` generates a set of error messages. The `msg` value is added to the set
# if the statements in the rule are true. If any of the statements are false or
# undefined, `msg` is not included in the set.
deny[msg] {
	# `input` is a global variable bound to the data sent to OPA by Kubernetes. In Rego,
	# the `.` operator selects keys from objects. If a key is missing, no error
	# is generated. The statement is just undefined.
	value := input.request.object.metadata.labels.costcenter

	# Check if the label value is formatted correctly.
	not startswith(value, "cccode-")

	# Construct an error message to return to the user.
	msg := sprintf("Costcenter code must start with `cccode-`; found `%v`", [value])
}

# https://www.magalix.com/blog/enforce-that-all-kubernetes-container-images-must-have-a-label-that-is-not-latest-using-opa
requested_images = {img | img := input.request.object.spec.containers[_].image}
deny[msg] {
	# We are intersted in Pod requests only
	input.request.kind.kind == "Pod"
	# Combine the results of both "ensure" policies with a logical OR
	ensure
	# If the evaulation result is true, deny the request and send this message to the requestor
	msg := sprintf("Pod %v could not be created because it uses images that are tagged latest or images with no tags",[input.request.object.metadata.name])
}

ensure {
	# Does the image tag is latest? this should violate the policy
	has_string(":latest",requested_images)
}

ensure {
	# OR Is this a naked image? this should also violate the policy
	not has_string(":",requested_images)

}

has_string(str,arr){
	contains(arr[_],str)
}