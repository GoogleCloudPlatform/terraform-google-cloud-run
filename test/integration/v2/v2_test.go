// Copyright 2023 Google LLC
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

package v2

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func Testv2(t *testing.T) {
	run_v2 := tft.NewTFBlueprintTest(t)

	run_v2.DefineVerify(func(assert *assert.Assertions) {
		projectID := run_v2.GetTFSetupStringOutput("project_id")
		serviceName := run_v2.GetTFSetupStringOutput("service_name")
		serviceLocation := run_v2.GetTFSetupStringOutput("service_location")

		run_cmd := gcloud.Run(t, "run services describe", gcloud.WithCommonArgs([]string{serviceName, "--project", projectID, "--region", serviceLocation, "--format", "json"}))

		// T01: Verify if the Cloud Run Service deployed is in ACTIVE state
		assert.Equal("ACTIVE", run_cmd.Get("state").String(), fmt.Sprintf("Should be ACTIVE. Cloud Run service is not successfully deployed."))
	})
	run_v2.Test()
}
