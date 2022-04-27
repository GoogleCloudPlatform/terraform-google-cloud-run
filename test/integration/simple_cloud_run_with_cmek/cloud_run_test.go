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
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestCloudRun(t *testing.T) {

	cloud_run := tft.NewTFBlueprintTest(t)

	cloud_run.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			cloud_run.DefaultVerify(assert)

			op := gcloud.Run(t, fmt.Sprintf("--project=%s run services list --region=%s", cloud_run.GetStringOutput("project_id"), cloud_run.GetStringOutput("service_location")))
			assert.Equal(cloud_run.GetStringOutput("service_status"), op.Get("status.conditions.type"), "should have the right service status")
			// assert.True(op.Get("spec.template.metadadata.annotations.run.googleapis.com/encryption-key").Exists(), "does not have encryption key")
			// assert.Equal(cloud_run.GetStringOutput("encryption_key"), op.Get("spec.template.metadadata.annotations.run.googleapis.com/encryption-key"), "should have the right encryption key")

		})
	cloud_run.Test()
}
