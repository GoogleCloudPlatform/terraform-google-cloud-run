# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

control "gcloud" do
  title "gcloud"

  describe command("gcloud --project=#{attribute("project_id")} services list --enabled") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match "run.googleapis.com" }
  end

  describe command("gcloud --project=#{attribute("project_id")} run services describe #{attribute('service_name')} --region=#{attribute("service_location")} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let(:service) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it "has a GPU accelerator" do
      expect(service[:spec][:template][:spec][:nodeSelector][:"run.googleapis.com/accelerator"]).to eq "nvidia-l4"
    end

    it "has GPU resource limits" do
      expect(service[:spec][:template][:spec][:containers][0][:resources][:limits][:"nvidia.com/gpu"]).to eq "1"
    end
  end
end 
