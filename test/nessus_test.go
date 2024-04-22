package test

import (
  "crypto/tls"
	"testing"
	"fmt"
	"time"
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	//"github.com/stretchr/testify/assert"
)

func TestExamplesTerraform(t *testing.T) {
  t.Parallel()
  terraformOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: "../examples/terratest/",
  })

  defer terraform.Destroy(t, terraformOpts)
  terraform.InitAndApply(t, terraformOpts)

  awsRegion := terraform.Output(t, terraformOpts, "aws_region")
  asgName := terraform.Output(t, terraformOpts, "asg_name")

  instanceIds := aws.GetInstanceIdsForAsg(t, asgName, awsRegion)
	instanceIdsToIps := aws.GetPublicIpsOfEc2Instances(t, instanceIds, awsRegion)
  println(instanceIdsToIps)

  // Verify that the status returns
  tlsConfig := tls.Config{InsecureSkipVerify: true}
  public_ip := instanceIdsToIps[instanceIds[0]]
  url := fmt.Sprintf("https://%s:%s/%s", public_ip, "8834", "server/status")
  http_helper.HttpGetWithRetry(t, url, &tlsConfig, 200, "{\"code\":503,\"detailed_status\":{\"login_status\":\"allow\",\"feed_status\":{\"progress\":100,\"status\":\"ready\"},\"db_status\":{\"progress\":null,\"status\":\"register\"},\"engine_status\":{\"progress\":100,\"status\":\"ready\"}},\"pluginSet\":false,\"pluginData\":false,\"initLevel\":4,\"progress\":null,\"status\":\"register\"}", 10, 10*time.Second)

}
