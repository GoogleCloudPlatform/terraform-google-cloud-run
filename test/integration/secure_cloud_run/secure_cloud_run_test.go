// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cloud_run

import (
	"fmt"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

type Protocols struct {
	Protocol string
	Ports    []string
}

func getResultFieldStrSlice(rs []gjson.Result, field string) []string {
	s := make([]string, 0)
	for _, r := range rs {
		s = append(s, r.Get(field).String())
	}
	return s
}

func getPolicyID(t *testing.T, orgID string) string {
	terraformSa := utils.ValFromEnv(t, "TF_VAR_terraform_sa")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSa)
	saSplit := strings.SplitN(terraformSa, "/", 4)
	serviceaccount := saSplit[len(saSplit)-1]
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSa)
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s --impersonate-service-account=%s", orgID, serviceaccount), gcOpts)
	return op.String()
}

func TestSecureCloudRun(t *testing.T) {

	terraformSa := utils.ValFromEnv(t, "TF_VAR_terraform_sa")
	saSplit := strings.SplitN(terraformSa, "/", 4)
	serviceaccount := saSplit[len(saSplit)-1]
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSa)
	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	resourcesSuffix := utils.ValFromEnv(t, "TF_VAR_resource_names_suffix")
	policyID := getPolicyID(t, orgID)
	vars := map[string]string{
		"access_context_manager_policy_id": policyID,
	}
	secure_cloud_run := tft.NewTFBlueprintTest(t, tft.WithEnvVars(vars))

	secure_cloud_run.DefineVerify(func(assert *assert.Assertions) {

		vpcProjectId := secure_cloud_run.GetStringOutput("vpc_project_id")
		serverlessProjectId := secure_cloud_run.GetStringOutput("serverless_project_id")
		connectorId := secure_cloud_run.GetStringOutput("connector_id")

		kmsProjectName := secure_cloud_run.GetStringOutput("kms_project_id")
		kmsKeyRingName := secure_cloud_run.GetStringOutput("keyring_name")
		kmsKey := secure_cloud_run.GetStringOutput("key_name")
		opKMS := gcloud.Runf(t, "kms keys describe %s --keyring=%s --project=%s --location us-central1 --impersonate-service-account=%s", kmsKey, kmsKeyRingName, kmsProjectName, serviceaccount)
		keyFullName := fmt.Sprintf("projects/%s/locations/us-central1/keyRings/%s/cryptoKeys/%s", kmsProjectName, kmsKeyRingName, kmsKey)
		assert.Equal(keyFullName, opKMS.Get("name").String(), fmt.Sprintf("should have key %s", keyFullName))

		expectedImage := "us-docker.pkg.dev/cloudrun/container/hello"
		cloudRunName := "hello-world"
		opCloudRun := gcloud.Runf(t, "run services describe %s --region=us-central1 --project=%s --impersonate-service-account=%s", cloudRunName, serverlessProjectId, serviceaccount)
		annotations := opCloudRun.Get("spec.template.metadata.annotations").Map()
		assert.Equal(cloudRunName, opCloudRun.Get("metadata.name").String(), fmt.Sprintf("Should have same id: %s", cloudRunName))
		assert.Equal("1", annotations["autoscaling.knative.dev/minScale"].String(), "Should have minScale equals to 1")
		assert.Equal("2", annotations["autoscaling.knative.dev/maxScale"].String(), "Should have maxScale equals to 2")
		assert.Equal(connectorId, annotations["run.googleapis.com/vpc-access-connector"].String(), fmt.Sprintf("Should have %s VPC Access Connector Id", connectorId))
		assert.Equal(expectedImage, opCloudRun.Get("spec.template.spec.containers.0.image").String(), fmt.Sprintf("Should have %s image.", expectedImage))
		assert.Equal(keyFullName, annotations["run.googleapis.com/encryption-key"].String(), fmt.Sprintf("Should have same encryption-Key: %s", keyFullName))

		connectorName := fmt.Sprintf("con-run-%s", resourcesSuffix)
		expectedSubnet := fmt.Sprintf("vpc-subnet-%s", resourcesSuffix)
		expectedMachineType := "e2-micro"
		opVPCConnector := gcloud.Runf(t, "compute networks vpc-access connectors describe %s --region=us-central1 --project=%s --impersonate-service-account=%s", connectorName, serverlessProjectId, serviceaccount)
		assert.Equal(connectorId, opVPCConnector.Get("name").String(), fmt.Sprintf("Should have same id: %s", connectorId))
		assert.Equal(expectedSubnet, opVPCConnector.Get("subnet.name").String(), fmt.Sprintf("Should have same subnetwork: %s", expectedSubnet))
		assert.Equal(expectedMachineType, opVPCConnector.Get("machineType").String(), fmt.Sprintf("Should have same machineType: %s", expectedMachineType))
		assert.Equal("7", opVPCConnector.Get("maxInstances").String(), "Should have maxInstances equals to 7")
		assert.Equal("2", opVPCConnector.Get("minInstances").String(), "Should have minInstances equals to 2")
		assert.Equal("700", opVPCConnector.Get("maxThroughput").String(), "Should have maxThroughput equals to 700")
		assert.Equal("200", opVPCConnector.Get("minThroughput").String(), "Should have minThroughput equals to 200")

		expectedCloudArmorName := "cloud-armor-waf-policy"
		opCloudArmor := gcloud.Runf(t, "compute security-policies describe %s --project=%s --impersonate-service-account=%s", expectedCloudArmorName, serverlessProjectId, serviceaccount).Array()
		assert.Equal(expectedCloudArmorName, opCloudArmor[0].Get("name").String(), fmt.Sprintf("Cloud Armor name should be %s", expectedCloudArmorName))

		expectedLbName := "tf-cr-lb-address"
		opLoadBalancer := gcloud.Runf(t, "compute addresses describe %s --global --project=%s --impersonate-service-account=%s", expectedLbName, serverlessProjectId, serviceaccount).Array()
		assert.Equal(expectedLbName, opLoadBalancer[0].Get("name").String(), fmt.Sprintf("Load Balancer Name should be %s", expectedLbName))

		run_identity_services_sa := secure_cloud_run.GetStringOutput("run_identity_services_sa")
		iamFilter := fmt.Sprintf("bindings.members:'serviceAccount:%s'", run_identity_services_sa)
		iamOpts := gcloud.WithCommonArgs([]string{"--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
		orgIamPolicyRoles := gcloud.Run(t, fmt.Sprintf("projects get-iam-policy %s", vpcProjectId), iamOpts).Array()
		listRoles := getResultFieldStrSlice(orgIamPolicyRoles, "bindings.role")
		assert.Containsf(listRoles, "roles/vpcaccess.user", "Service account %s should have VPC Access User role", run_identity_services_sa)

		for _, orgPolicy := range []struct {
			constraint    string
			allowedValues string
		}{
			{
				constraint:    "constraints/run.allowedVPCEgress",
				allowedValues: "private-ranges-only",
			},
			{
				constraint:    "constraints/run.allowedIngress",
				allowedValues: "is:internal-and-cloud-load-balancing",
			},
		} {
			policyFor := secure_cloud_run.GetStringOutput("policy_for")
			folderId := secure_cloud_run.GetStringOutput("folder_id")
			orgId := secure_cloud_run.GetStringOutput("organization_id")
			orgArgs := gcloud.WithCommonArgs([]string{"--flatten", "listPolicy.allowedValues[]", "--format", "json"})
			if policyFor == "project" {
				opOrgPoliciesPrj := gcloud.Run(t, fmt.Sprintf("resource-manager org-policies describe %s --project=%s", orgPolicy.constraint, serverlessProjectId), orgArgs).Array()
				assert.Equal(orgPolicy.allowedValues, opOrgPoliciesPrj[0].Get("listPolicy.allowedValues").String(), fmt.Sprintf("Constraint %s should have policy %s", orgPolicy.constraint, orgPolicy.allowedValues))
			}
			if policyFor == "folder" {
				opOrgPoliciesFld := gcloud.Run(t, fmt.Sprintf("resource-manager org-policies describe %s --folder=%s", orgPolicy.constraint, folderId), orgArgs).Array()
				assert.Equal(orgPolicy.allowedValues, opOrgPoliciesFld[0].Get("listPolicy.allowedValues").String(), fmt.Sprintf("Constraint %s should have policy %s", orgPolicy.constraint, orgPolicy.allowedValues))
			}
			if policyFor == "organization" {
				opOrgPolicies := gcloud.Run(t, fmt.Sprintf("resource-manager org-policies describe %s --organization=%s", orgPolicy.constraint, orgId), orgArgs).Array()
				assert.Equal(orgPolicy.allowedValues, opOrgPolicies[0].Get("listPolicy.allowedValues").String(), fmt.Sprintf("Constraint %s should have policy %s", orgPolicy.constraint, orgPolicy.allowedValues))
			}
		}
		// Firewall Rules
		for _, firewall_rules := range []struct {
			name       string
			direction  string
			ranges     []string
			targetTags []string
			sourceTags []string
			allow      []Protocols
		}{
			{
				name:       "fw-serverless-to-vpc-connector",
				direction:  "INGRESS",
				ranges:     []string{"107.178.230.64/26", "35.199.224.0/19"},
				targetTags: []string{"vpc-connector"},
				sourceTags: []string{},
				allow: []Protocols{Protocols{
					Protocol: "icmp",
					Ports:    []string{},
				},
					Protocols{
						Protocol: "tcp",
						Ports:    []string{"667"},
					},
					Protocols{
						Protocol: "udp",
						Ports:    []string{"665", "666"},
					}},
			},
			{
				name:       "fw-vpc-connector-to-serverless",
				direction:  "EGRESS",
				ranges:     []string{"107.178.230.64/26", "35.199.224.0/19"},
				targetTags: []string{"vpc-connector"},
				sourceTags: []string{},
				allow: []Protocols{Protocols{
					Protocol: "icmp",
					Ports:    []string{},
				},
					Protocols{
						Protocol: "tcp",
						Ports:    []string{"667"},
					},
					Protocols{
						Protocol: "udp",
						Ports:    []string{"665", "666"},
					}},
			},
			{
				name:       "fw-vpc-connector-health-checks",
				direction:  "INGRESS",
				ranges:     []string{"130.211.0.0/22", "35.191.0.0/16", "108.170.220.0/23"},
				targetTags: []string{"vpc-connector"},
				sourceTags: []string{},
				allow: []Protocols{
					Protocols{
						Protocol: "tcp",
						Ports:    []string{"667"},
					},
				},
			},
			{
				name:       "fw-vpc-connector-requests",
				direction:  "INGRESS",
				ranges:     []string{},
				sourceTags: []string{"vpc-connector"},
				targetTags: []string{},
				allow: []Protocols{Protocols{
					Protocol: "icmp",
					Ports:    []string{},
				},
					Protocols{
						Protocol: "tcp",
						Ports:    []string{},
					},
					Protocols{
						Protocol: "udp",
						Ports:    []string{},
					},
				},
			},
			{
				name:       "fw-vpc-connector-to-lb",
				direction:  "EGRESS",
				ranges:     []string{"0.0.0.0/0"},
				targetTags: []string{"vpc-connector"},
				sourceTags: []string{},
				allow: []Protocols{Protocols{
					Protocol: "tcp",
					Ports:    []string{"80"},
				},
				},
			},
		} {
			fwRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", firewall_rules.name, vpcProjectId)
			assert.Equal(firewall_rules.name, fwRule.Get("name").String(), fmt.Sprintf("firewall rule %s should exist", firewall_rules.name))
			assert.Equal(firewall_rules.direction, fwRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be %s", firewall_rules.name, firewall_rules.direction))
			assert.False(fwRule.Get("disabled").Bool(), fmt.Sprintf("firewall rule %s should be ENABLED", firewall_rules.name))
			assert.True(fwRule.Get("logConfig.enable").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", firewall_rules.name))
			assert.Equal("INCLUDE_ALL_METADATA", fwRule.Get("logConfig.metadata").String(), fmt.Sprintf("firewall rule %s should have log configuration metadata as INCLUDE_ALL_METADATA", firewall_rules.name))

			if firewall_rules.direction == "EGRESS" {
				assert.Equal(utils.GetResultStrSlice(fwRule.Get("destinationRanges").Array()), firewall_rules.ranges, fmt.Sprintf("firewall rule %s destination ranges should be %v", firewall_rules.name, firewall_rules.ranges))
			} else {
				assert.Equal(utils.GetResultStrSlice(fwRule.Get("sourceRanges").Array()), firewall_rules.ranges, fmt.Sprintf("firewall rule %s source ranges should be %v", firewall_rules.name, firewall_rules.ranges))
			}

			assert.Equal(firewall_rules.targetTags, utils.GetResultStrSlice(fwRule.Get("targetTags").Array()), fmt.Sprintf("firewall rule %s target tags should be %v", firewall_rules.name, firewall_rules.targetTags))
			assert.Equal(firewall_rules.sourceTags, utils.GetResultStrSlice(fwRule.Get("sourceTags").Array()), fmt.Sprintf("firewall rule %s source tags should be %v", firewall_rules.name, firewall_rules.sourceTags))

			assert.Equal(len(firewall_rules.allow), len(utils.GetResultStrSlice(fwRule.Get("allowed").Array())), fmt.Sprintf("firewall rule %s should have %d allowed", firewall_rules.name, len(firewall_rules.allow)))
			for _, allow := range firewall_rules.allow {
				assert.Contains(getResultFieldStrSlice(fwRule.Get("allowed").Array(), "IPProtocol"), allow.Protocol, fmt.Sprintf("firewall rule %s should allow %v protocol", firewall_rules.name, allow.Protocol))
				allowed := fwRule.Get("allowed").Array()
				for _, protocol := range allowed {
					if protocol.Get("IPProtocol").String() == allow.Protocol {
						assert.Equal(utils.GetResultStrSlice(protocol.Get("ports").Array()), allow.Ports, fmt.Sprintf("firewall rule %s should allow only %s port to the protocol %s ", firewall_rules.name, allow.Ports, allow.Protocol))
					}
				}
			}
		}
	})

	secure_cloud_run.Test()
}
