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

package simple_cloud_run_with_cmek

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestCloudRunWithCMEK(t *testing.T) {

	cloud_run := tft.NewTFBlueprintTest(t)

	cloud_run.DefineVerify(
		func(assert *assert.Assertions) {
			projectID := cloud_run.GetStringOutput("project_id")
			location := cloud_run.GetStringOutput("service_location")
			serviceStatus := cloud_run.GetStringOutput("service_status")
			encryption_key := cloud_run.GetStringOutput("encryption_key")
			gcOps := gcloud.WithCommonArgs([]string{"--project", projectID, "--region", location, "--format", "json"})

			op := gcloud.Run(t, "run services list", gcOps).Array()[0]
			annotations := op.Get("spec").Get("template").Get("metadata").Get("annotations").Value().(map[string]interface{})

			assert.Equal(serviceStatus, op.Get("status").Get("conditions").Array()[0].Get("type").String(), "should have the right service status")
			assert.Equal(encryption_key, annotations["run.googleapis.com/encryption-key"], "should have the right encryption key")

		})
	cloud_run.Test()
}
