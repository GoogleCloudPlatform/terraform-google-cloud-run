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

package job_service_account_creation

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestJobServiceAccountCreation(t *testing.T) {
	jobSACreation := tft.NewTFBlueprintTest(t)

	jobSACreation.DefineVerify(func(assert *assert.Assertions) {
		jobSACreation.DefaultVerify(assert)

		projectID := jobSACreation.GetTFSetupStringOutput("project_id")
		saEmail := jobSACreation.GetJsonOutput("service_account_id").Get("email").String()

		sa := gcloud.Run(t, "iam service-accounts describe", gcloud.WithCommonArgs([]string{saEmail, "--project", projectID, "--format", "json"}))
		assert.Equal(saEmail, sa.Get("email").String(), fmt.Sprintf("Service account should have been created."))
	})
	jobSACreation.Test()
}
