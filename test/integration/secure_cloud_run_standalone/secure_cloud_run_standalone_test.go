// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cloudrun

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func getPolicyID(t *testing.T, orgID string) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

// getResultFieldStrSlice parses a field of a results list into a string slice
func getResultFieldStrSlice(rs []gjson.Result, field string) []string {
	s := make([]string, 0)
	for _, r := range rs {
		s = append(s, r.Get(field).String())
	}
	return s
}

func TestSecureCloudRunStandalone(t *testing.T) {
	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(t, orgID)
	vars := map[string]string{
		"access_context_manager_policy_id": policyID,
		"access_level_members":             fmt.Sprintf("[\"serviceAccount:%s\"]", utils.ValFromEnv(t, "TF_VAR_sa_email")),
		"domain":                           fmt.Sprintf("[\"%s\"]", utils.ValFromEnv(t, "TF_VAR_domain")),
	}

	cloudRun := tft.NewTFBlueprintTest(t, tft.WithEnvVars(vars))

	restrictedServices := []string{
		"cloudkms.googleapis.com",
		"run.googleapis.com",
		"artifactregistry.googleapis.com",
		"containerregistry.googleapis.com",
		"containeranalysis.googleapis.com",
		"binaryauthorization.googleapis.com",
	}

	cloudRun.DefineVerify(
		func(assert *assert.Assertions) {
			location := "us-west1"
			serverlessProjectID := cloudRun.GetStringOutput("serverless_project_id")
			serverlessProjectNumber := cloudRun.GetStringOutput("serverless_project_number")
			securityProjectID := cloudRun.GetStringOutput("security_project_id")
			securityProjectNumber := cloudRun.GetStringOutput("security_project_number")
			networkName := cloudRun.GetStringOutput("service_vpc_name")
			connectorId := cloudRun.GetStringOutput("connector_id")
			cloudRunServiceIdentity := fmt.Sprintf("serviceAccount:service-%s@serverless-robot-prod.iam.gserviceaccount.com", serverlessProjectNumber)
			artifactRegistryServiceIdentity := fmt.Sprintf("serviceAccount:service-%s@gcp-sa-artifactregistry.iam.gserviceaccount.com", securityProjectNumber)
			servicePerimeterLink := fmt.Sprintf("accessPolicies/%s/servicePerimeters/%s", policyID, cloudRun.GetStringOutput("restricted_service_perimeter_name"))
			accessLevel := fmt.Sprintf("accessPolicies/%s/accessLevels/%s", policyID, cloudRun.GetStringOutput("restricted_access_level_name"))

			// VPC-SC Tests
			servicePerimeter := gcloud.Runf(t, "access-context-manager perimeters describe %s --policy %s", servicePerimeterLink, policyID)
			assert.Equal(servicePerimeterLink, servicePerimeter.Get("name").String(), fmt.Sprintf("service perimeter %s should exist", servicePerimeterLink))
			listLevels := utils.GetResultStrSlice(servicePerimeter.Get("status.accessLevels").Array())
			assert.Contains(listLevels, accessLevel, fmt.Sprintf("service perimeter %s should have access level %s", servicePerimeterLink, accessLevel))
			listServices := utils.GetResultStrSlice(servicePerimeter.Get("status.restrictedServices").Array())
			assert.Subset(listServices, restrictedServices, fmt.Sprintf("service perimeter %s should restrict %v", servicePerimeterLink, restrictedServices))

			// Network test
			opCloudRun := gcloud.Runf(t, "compute networks describe %s --project=%s", networkName, serverlessProjectID)
			assert.Equal("GLOBAL", opCloudRun.Get("routingConfig.routingMode").String(), fmt.Sprint("Routing Mode should be GLOBAL."))

			// Sub-network test
			subnetName := cloudRun.GetStringOutput("service_vpc_subnet_name")
			subNetRange := "10.0.0.0/28"
			subnet := gcloud.Runf(t, "compute networks subnets describe %s --region %s --project %s", subnetName, location, serverlessProjectID)
			assert.Equal(subnetName, subnet.Get("name").String(), fmt.Sprintf("subnet %s should exist", subnetName))
			assert.Equal(subNetRange, subnet.Get("ipCidrRange").String(), fmt.Sprintf("IP CIDR range %s should be", subNetRange))

			// Firewall - Deny all egress test
			denyAllEgressName := "fw-e-shared-restricted-65535-e-d-all-all-all"
			denyAllEgressRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", denyAllEgressName, serverlessProjectID)
			assert.Equal(denyAllEgressName, denyAllEgressRule.Get("name").String(), fmt.Sprintf("firewall rule %s should exist", denyAllEgressName))
			assert.Equal("EGRESS", denyAllEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", denyAllEgressName))
			assert.True(denyAllEgressRule.Get("logConfig.enable").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", denyAllEgressName))
			assert.Equal("0.0.0.0/0", denyAllEgressRule.Get("destinationRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be 0.0.0.0/0", denyAllEgressName))
			assert.Equal(1, len(denyAllEgressRule.Get("denied").Array()), fmt.Sprintf("firewall rule %s should have only one denied", denyAllEgressName))
			assert.Equal(1, len(denyAllEgressRule.Get("denied.0").Map()), fmt.Sprintf("firewall rule %s should have only one denied only with no ports", denyAllEgressName))
			assert.Equal("all", denyAllEgressRule.Get("denied.0.IPProtocol").String(), fmt.Sprintf("firewall rule %s should deny all protocols", denyAllEgressName))

			// Firewall - Allow Restricted APIs
			allowApiEgressName := "fw-e-shared-restricted-65534-e-a-allow-google-apis-all-tcp-443"
			allowApiEgressRule := gcloud.Runf(t, "compute firewall-rules describe %s --project %s", allowApiEgressName, serverlessProjectID)
			assert.Equal(allowApiEgressName, allowApiEgressRule.Get("name").String(), fmt.Sprintf("firewall rule %s should exist", allowApiEgressName))
			assert.Equal("EGRESS", allowApiEgressRule.Get("direction").String(), fmt.Sprintf("firewall rule %s direction should be EGRESS", allowApiEgressName))
			assert.True(allowApiEgressRule.Get("logConfig.enable").Bool(), fmt.Sprintf("firewall rule %s should have log configuration enabled", allowApiEgressName))
			assert.Equal("10.3.0.5", allowApiEgressRule.Get("destinationRanges").Array()[0].String(), fmt.Sprintf("firewall rule %s destination ranges should be %s", allowApiEgressName, subNetRange))
			assert.Equal(1, len(allowApiEgressRule.Get("allowed").Array()), fmt.Sprintf("firewall rule %s should have only one allowed", allowApiEgressName))
			assert.Equal(2, len(allowApiEgressRule.Get("allowed.0").Map()), fmt.Sprintf("firewall rule %s should have only one allowed only with protocol end ports", allowApiEgressName))
			assert.Equal("tcp", allowApiEgressRule.Get("allowed.0.IPProtocol").String(), fmt.Sprintf("firewall rule %s should allow tcp protocol", allowApiEgressName))
			assert.Equal(1, len(allowApiEgressRule.Get("allowed.0.ports").Array()), fmt.Sprintf("firewall rule %s should allow only one port", allowApiEgressName))
			assert.Equal("443", allowApiEgressRule.Get("allowed.0.ports.0").String(), fmt.Sprintf("firewall rule %s should allow port 443", allowApiEgressName))

			// Artifact Registry KMS tests
			keyRingName := "krg-secure-artifact-registry"
			keyRingFullName := fmt.Sprintf("projects/%s/locations/%s/keyRings/%s", securityProjectID, location, keyRingName)
			keyName := "key-secure-artifact-registry"
			keyFullName := fmt.Sprintf("projects/%s/locations/%s/keyRings/%s/cryptoKeys/%s", securityProjectID, location, keyRingName, keyName)

			kmsArtifactRegistryKeyring := gcloud.Runf(t, "kms keyrings describe %s --project %s --location %s", keyRingName, securityProjectID, location)
			assert.Equal(keyRingFullName, kmsArtifactRegistryKeyring.Get("name").String(), fmt.Sprintf("KMS keyring %s should exist", keyRingFullName))

			kmsArtifactRegistryKey := gcloud.Runf(t, "kms keys describe %s --project %s --location %s --keyring %s", keyName, securityProjectID, location, keyRingName)
			assert.Equal(keyFullName, kmsArtifactRegistryKey.Get("name").String(), fmt.Sprintf("KMS key %s should exist", keyFullName))

			// Encrypt and Decrypt roles for Cloud Run Service Identity test
			encryptDecryptRoles := []string{"roles/cloudkms.cryptoKeyEncrypter", "roles/cloudkms.cryptoKeyDecrypter"}
			iamFilter := fmt.Sprintf("bindings.members:'%s'", artifactRegistryServiceIdentity)
			iamOpts := gcloud.WithCommonArgs([]string{"--location", location, "--project", securityProjectID, "--keyring", keyRingName, "--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
			kmsArtifactRegistryKeyIAM := gcloud.Run(t, fmt.Sprintf("kms keys get-iam-policy %s", keyName), iamOpts).Array()
			listRoles := getResultFieldStrSlice(kmsArtifactRegistryKeyIAM, "bindings.role")
			assert.Subset(listRoles, encryptDecryptRoles, "Artifact Registry should have %s 'roles/cloudkms.cryptoKeyEncrypter' and 'cloudkms.cryptoKeyDecrypter' roles", cloudRunServiceIdentity)

			// Atifact Registry tests
			artifactRegistryName := "rep-secure-cloud-run"
			artifactRegistryFullName := fmt.Sprintf("projects/%s/locations/us-west1/repositories/%s", securityProjectID, artifactRegistryName)
			artifactRegistry := gcloud.Runf(t, "artifacts repositories describe %s --location %s --project %s", artifactRegistryName, location, securityProjectID)
			assert.Equal(artifactRegistryFullName, artifactRegistry.Get("name").String(), fmt.Sprintf("KMS key %s should exist", artifactRegistryFullName))
			assert.Equal("DOCKER", artifactRegistry.Get("format").String(), fmt.Sprint("Format should be DOCKER"))
			assert.Equal(kmsArtifactRegistryKey.Get("name").String(), artifactRegistry.Get("kmsKeyName").String(), fmt.Sprintf("Artifact Registry should have encryption key %s", kmsArtifactRegistryKey.Get("name").String()))

			// Cloud Run Service Identity IAM test
			iamFilter = fmt.Sprintf("bindings.members:'%s'", cloudRunServiceIdentity)
			iamOpts = gcloud.WithCommonArgs([]string{"--location", location, "--project", securityProjectID, "--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
			artifactRegistryIAMPolicy := gcloud.Run(t, fmt.Sprintf("artifacts repositories get-iam-policy %s", artifactRegistryName), iamOpts).Array()
			listRoles = getResultFieldStrSlice(artifactRegistryIAMPolicy, "bindings.role")
			assert.Subset(listRoles, []string{"roles/artifactregistry.reader"}, "Artifact Registry should have %s roles/artifactregistry.reader role", cloudRunServiceIdentity)

			// Service account test
			serviceAccountName := "sa-cloud-run"
			serviceAccountEmail := fmt.Sprintf("%s@%s.iam.gserviceaccount.com", serviceAccountName, serverlessProjectID)
			serviceAccountID := fmt.Sprintf("projects/%s/serviceAccounts/%s", serverlessProjectID, serviceAccountEmail)
			serviceAccount := gcloud.Runf(t, "iam service-accounts describe %s", serviceAccountEmail)
			assert.Equal(serviceAccountID, serviceAccount.Get("name").String(), fmt.Sprintf("Service Account %s should exist", serviceAccountID))

			//Cloud Run test
			expectedImage := fmt.Sprintf("%s-docker.pkg.dev/%s/%s/hello:latest", location, securityProjectID, artifactRegistryName)
			cloudRunName := "srv-secure-cloud-run"
			keyRingName = "krg-secure-cloud-run"
			keyRingFullName = fmt.Sprintf("projects/%s/locations/%s/keyRings/%s", securityProjectID, location, keyRingName)
			keyName = "key-secure-cloud-run"
			keyFullName = fmt.Sprintf("%s/cryptoKeys/%s", keyRingFullName, keyName)
			opCloudRun = gcloud.Runf(t, "run services describe %s --region=%s --project=%s", cloudRunName, location, serverlessProjectID)
			annotations := opCloudRun.Get("spec.template.metadata.annotations").Map()
			assert.Equal(cloudRunName, opCloudRun.Get("metadata.name").String(), fmt.Sprintf("Should have same id: %s", cloudRunName))
			assert.Equal("1", annotations["autoscaling.knative.dev/minScale"].String(), "Should have minScale equals to 1")
			assert.Equal("2", annotations["autoscaling.knative.dev/maxScale"].String(), "Should have maxScale equals to 2")
			assert.Equal(connectorId, annotations["run.googleapis.com/vpc-access-connector"].String(), fmt.Sprintf("Should have %s VPC Access Connector Id", connectorId))
			assert.Equal(expectedImage, opCloudRun.Get("spec.template.spec.containers.0.image").String(), fmt.Sprintf("Should have %s image.", expectedImage))
			assert.Equal(keyFullName, annotations["run.googleapis.com/encryption-key"].String(), fmt.Sprintf("Should have same encryption-Key: %s", keyFullName))

			// VPC test
			connectorName := "con-secure-cloud-run"
			expectedSubnet := fmt.Sprintf("sb-restricted-%s", location)
			expectedMachineType := "e2-micro"
			opVPCConnector := gcloud.Runf(t, "compute networks vpc-access connectors describe %s --region=%s --project=%s", connectorName, location, serverlessProjectID)
			assert.Equal(connectorId, opVPCConnector.Get("name").String(), fmt.Sprintf("Should have same id: %s", connectorId))
			assert.Equal(expectedSubnet, opVPCConnector.Get("subnet.name").String(), fmt.Sprintf("Should have same subnetwork: %s", expectedSubnet))
			assert.Equal(expectedMachineType, opVPCConnector.Get("machineType").String(), fmt.Sprintf("Should have same machineType: %s", expectedMachineType))
			assert.Equal("7", opVPCConnector.Get("maxInstances").String(), "Should have maxInstances equals to 7")
			assert.Equal("2", opVPCConnector.Get("minInstances").String(), "Should have minInstances equals to 2")
			assert.Equal("700", opVPCConnector.Get("maxThroughput").String(), "Should have maxThroughput equals to 700")
			assert.Equal("200", opVPCConnector.Get("minThroughput").String(), "Should have minThroughput equals to 200")

			// Cloud Armor tests
			expectedCloudArmorName := "cloud-armor-waf-policy"
			opCloudArmor := gcloud.Runf(t, "compute security-policies describe %s --project=%s", expectedCloudArmorName, serverlessProjectID).Array()
			assert.Equal(expectedCloudArmorName, opCloudArmor[0].Get("name").String(), fmt.Sprintf("Cloud Armor name should be %s", expectedCloudArmorName))

			// Load Balancer test
			expectedLbName := "tf-cr-lb-address"
			opLoadBalancer := gcloud.Runf(t, "compute addresses describe %s --global --project=%s", expectedLbName, serverlessProjectID).Array()
			assert.Equal(expectedLbName, opLoadBalancer[0].Get("name").String(), fmt.Sprintf("Load Balancer Name should be %s", expectedLbName))

			// Org Policy test
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
				orgArgs := gcloud.WithCommonArgs([]string{"--flatten", "listPolicy.allowedValues[]", "--format", "json"})
				opOrgPolicies := gcloud.Run(t, fmt.Sprintf("resource-manager org-policies describe %s --project=%s", orgPolicy.constraint, serverlessProjectID), orgArgs).Array()
				assert.Equal(orgPolicy.allowedValues, opOrgPolicies[0].Get("listPolicy.allowedValues").String(), fmt.Sprintf("Constraint %s should have policy %s", orgPolicy.constraint, orgPolicy.allowedValues))
			}
		})

	cloudRun.Test()
}
