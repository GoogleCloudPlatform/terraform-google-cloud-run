// Copyright 2025 Google LLC
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

package v2_with_gpu

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestV2WithGPU(t *testing.T) {
	runV2WithGPU := tft.NewTFBlueprintTest(t)

	runV2WithGPU.DefineVerify(func(assert *assert.Assertions) {
		runV2WithGPU.DefaultVerify(assert)

		projectID := runV2WithGPU.GetTFSetupStringOutput("project_id")
		serviceName := runV2WithGPU.GetStringOutput("service_name")
		serviceLocation := runV2WithGPU.GetStringOutput("service_location")

		run_cmd := gcloud.Run(t, "run services describe", gcloud.WithCommonArgs([]string{serviceName, "--project", projectID, "--region", serviceLocation, "--format", "json"}))

		// Verify the Cloud Run Service deployed is in ready state.
		readyCondition := utils.GetFirstMatchResult(t, run_cmd.Get("status.conditions").Array(), "type", "Ready")
		assert.Equal("True", readyCondition.Get("status").String(), fmt.Sprintf("Should be in ready status"))

		// Verify GPU-specific configurations
		// Check that the service has the correct GPU accelerator node selector
		accelerator := run_cmd.Get("spec.template.spec.nodeSelector.run\\.googleapis\\.com/accelerator").String()
		assert.Equal("nvidia-l4", accelerator, "Should have nvidia-l4 accelerator configured")

		// Check that the container has GPU resource limits
		gpuLimit := run_cmd.Get("spec.template.spec.containers.0.resources.limits.nvidia\\.com/gpu").String()
		assert.Equal("1", gpuLimit, "Should have 1 GPU configured in resource limits")
	})
	runV2WithGPU.Test()
}
