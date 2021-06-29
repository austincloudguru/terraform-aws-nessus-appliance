package test

import (
	"testing"
	"fmt"
	"time"
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/aws"
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
  albTg := terraform.Output(t, terraformOpts, "target_group_name")
  assert.Equal(t, albTg, "terratest")

  // Verify that the certs 
  tfCertArn := terraform.Output(t, terraformOpts, "certificate_arn")
  awsCertArn := aws.GetAcmCertificateArn(t, "us-west-2", "terratest.austincloud.net")
  assert.Equal(t, awsCertArn, tfCertArn)

   // Verify that the domain returns the default 404
   fqdn := terraform.Output(t, terraformOpts, "fqdn")
   url := fmt.Sprintf("http://%s", fqdn)
   http_helper.HttpGetWithRetry(t, url, nil, 404, "404 Not Found", 10, 10*time.Second)

}
