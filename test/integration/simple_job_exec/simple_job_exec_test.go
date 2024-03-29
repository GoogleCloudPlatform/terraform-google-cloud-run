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

package simple_job_exec

import (
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestSimpleJobExec(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)
	example.DefineVerify(func(assert *assert.Assertions) {
		// no default verify as there are some server side diffs
		projectID := example.GetTFSetupStringOutput("project_id")
		jobSucceeded := func() (bool, error) {
			op := gcloud.Runf(t, "beta run jobs executions list --job simple-job --project %s --region us-central1", projectID).Array()
			assert.Equal(1, len(op), "job should be executed once")
			if op[0].Get("status.succeededCount").Int() != 1 {
				// retry if not success yet
				return true, nil
			}
			return false, nil
		}
		utils.Poll(t, jobSucceeded, 10, time.Second*10)
	})
	example.Test()
}
