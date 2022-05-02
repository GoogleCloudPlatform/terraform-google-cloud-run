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

package simple_cloudRun_with_cmek

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestCloudRunWithCMEK(t *testing.T) {

	cloudRun := tft.NewTFBlueprintTest(t)

	cloudRun.DefineVerify(
		func(assert *assert.Assertions) {
			projectID := cloudRun.GetStringOutput("project_id")
			location := cloudRun.GetStringOutput("service_location")
			serviceStatus := cloudRun.GetStringOutput("service_status")
			encryptionKey := cloudRun.GetStringOutput("encryption_key")
			gcOps := gcloud.WithCommonArgs([]string{"--project", projectID, "--region", location, "--format", "json"})

			op := gcloud.Run(t, "run services list", gcOps).Array()[0]
			annotations := op.Get("spec").Get("template").Get("metadata").Get("annotations").Map()

			assert.Equal(serviceStatus, op.Get("status").Get("conditions").Array()[0].Get("type").String(), "should have the right service status")
			assert.Equal(encryptionKey, annotations["run.googleapis.com/encryption-key"].String(), "should have the right encryption key")

		})
	cloudRun.Test()
}
