package test

import (
  "crypto/tls"
	"testing"
	"fmt"
	"time"
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	//"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExamplesTerraform(t *testing.T) {
  t.Parallel()
  terraformOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: "../examples/terratest/",
  })

  defer terraform.Destroy(t, terraformOpts)
  terraform.InitAndApply(t, terraformOpts)

  // Verify that the ALB is created
  tfImageId := terraform.Output(t, terraformOpts, "image_id")
  assert.Equal(t, tfImageId, "ami-023dd6394b8980892")

  // Verify that the status returns
  tlsConfig := tls.Config{InsecureSkipVerify: true}
  public_ip := terraform.Output(t, terraformOpts, "instance_public_ip")
  url := fmt.Sprintf("https://%s:%s/%s", public_ip, "8834", "server/status")
  http_helper.HttpGetWithRetry(t, url, &tlsConfig, 200, "{\"code\":503,\"progress\":null,\"status\":\"register\"}", 10, 10*time.Second)

}
