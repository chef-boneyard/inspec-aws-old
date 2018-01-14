fixtures = {}
[
  's3_bucket_public_name',
  's3_bucket_private_name',
  's3_bucket_auth_name',
  's3_bucket_public_region',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/s3.tf',
  )
end

control 'aws_s3_bucket recall tests' do
  #------------------- Exists -------------------#
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']) do
    it { should exist }
  end

  #------------------- Does Not Exist -------------------#
  describe aws_s3_bucket(bucket_name: 'inspec-testing-NonExistentBucket.chef.io') do
    it { should_not exist }
  end
end

control 'aws_s3_bucket properties tests' do
  #--------------------------- Region --------------------------#
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']) do
    its('region') { should eq fixtures['s3_bucket_public_region'] }
  end

  #-------------------  public_objects  -------------------#
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']) do
    skip
    #its('public_objects') { should include "public-pic.png" }
  end
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_private_name']) do
    skip
    #its('public_objects') { should be_empty }
  end

  #------------------- bucket_acl -------------------#
  describe "Public grants on a public bucket" do
    subject do
      aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']).bucket_acl.select do |g|
        g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
      end
    end
    it { should_not be_empty }
  end
  
  describe "Public grants on a private bucket" do
    subject do
      aws_s3_bucket(bucket_name: fixtures['s3_bucket_private_name']).bucket_acl.select do |g|
        g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
      end
    end
    it { should be_empty }
  end

  describe "AuthUser grants on a private bucket" do
    subject do
      aws_s3_bucket(bucket_name: fixtures['s3_bucket_private_name']).bucket_acl.select do |g|
        g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
      end
    end
    it { should be_empty }
  end

  describe "AuthUser grants on an AuthUser bucket" do
    subject do
      aws_s3_bucket(bucket_name: fixtures['s3_bucket_auth_name']).bucket_acl.select do |g|
        g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
      end
    end
    it { should_not be_empty }
  end
end

control 'aws_s3_bucket matchers test' do
  
  #------------------------  be_public --------------------------#  
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']) do
    skip
    # it { should be_public }
  end
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_auth_name']) do
    skip
    #it { should be_public }
  end
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_private_name']) do
    skip
    #it { should_not be_public }
  end

  #------------------------ has_public_objects --------------------------#  
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_public_name']) do
    skip
    #it { should have_public_objects }
  end
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_private_name']) do
    skip
    #it { should_not have_public_objects }
  end
end
