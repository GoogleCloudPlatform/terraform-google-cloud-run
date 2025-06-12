package v2_with_iap

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestV2WithIAP(t *testing.T) {
	runV2IAP := tft.NewTFBlueprintTest(t)

	runV2IAP.DefineVerify(func(assert *assert.Assertions) {
		// runV2IAP.DefaultVerify(assert)

		projectID := runV2IAP.GetTFSetupStringOutput("project_id")
		serviceName := runV2IAP.GetStringOutput("service_name")
		serviceLocation := runV2IAP.GetStringOutput("service_location")

		runCmd := gcloud.Run(t, "run services describe", gcloud.WithCommonArgs([]string{serviceName, "--project", projectID, "--region", serviceLocation, "--format", "json"}))

		// Verify the Cloud Run Service deployed is in ready state.
		readyCondition := utils.GetFirstMatchResult(t, runCmd.Get("status").Get("conditions").Array(), "type", "Ready")
		assert.Equal("True", readyCondition.Get("status").String(), fmt.Sprintf("Should be in ready status"))
	})
	runV2IAP.Test()
}
