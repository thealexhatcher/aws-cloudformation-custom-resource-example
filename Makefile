SHELL := /bin/bash
STACKNAME?= "aws-cloudformation-custom-resource-example"
S3_BUCKET?= "OVERRIDE_REQUIRED" #OVERRIDE THIS BUCKET NAME
S3_PREFIX?= "local"

clean:
	rm -rf ./custom_resource_preprocess/package
	rm -f custom_resource_preprocess/template.out.yml
	rm -rf ./custom_resource_postprocess/package
	rm -f custom_resource_postprocess/template.out.yml
	rm -f example.out.yml
	rm -f resources.out.yml
validate:
	aws cloudformation validate-template --template-body file://custom_resource_preprocess/template.yml --output text
	aws cloudformation validate-template --template-body file://custom_resource_postprocess/template.yml --output text
	aws cloudformation validate-template --template-body file://resources.yml --output text
build: validate clean 
	cd custom_resource_preprocess \
		&& mkdir package \
		&& find . ! -regex '.*/package' ! -regex '.' -exec cp -r '{}' package \;\
		&& pip3 install -r requirements.txt -t ./package 
	cd custom_resource_postprocess \
		&& mkdir package \
		&& find . ! -regex '.*/package' ! -regex '.' -exec cp -r '{}' package \;\
		&& pip3 install -r requirements.txt -t ./package 
package: build
	aws cloudformation package --template-file custom_resource_preprocess/template.yml --s3-bucket $(S3_BUCKET) --s3-prefix $(S3_PREFIX) --output-template-file custom_resource_preprocess/template.out.yml
	aws cloudformation package --template-file custom_resource_postprocess/template.yml --s3-bucket $(S3_BUCKET) --s3-prefix $(S3_PREFIX) --output-template-file custom_resource_postprocess/template.out.yml
	aws cloudformation package --template-file example.yml --s3-bucket $(S3_BUCKET) --s3-prefix $(S3_PREFIX) --output-template-file example.out.yml
	aws cloudformation package --template-file resources.yml --s3-bucket $(S3_BUCKET) --s3-prefix $(S3_PREFIX) --output-template-file resources.out.yml
deploy: package 
	aws cloudformation deploy --stack-name $(STACKNAME) --template-file resources.out.yml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND 
destroy:
	aws cloudformation delete-stack --stack-name $(STACKNAME) && aws cloudformation wait stack-delete-complete --stack-name $(STACKNAME)
