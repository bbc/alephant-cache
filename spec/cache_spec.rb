require 'spec_helper'
require 'pry'

describe Alephant::Cache do
  let(:id)   { :id }
  let(:path) { :path }
  let(:data) { :data }
  subject { Alephant::Cache }

  describe "initialize(id, path)" do
    it "sets and exposes id, path instance variables " do
      instance = subject.new(id, path)
      expect(instance.id).to eq(id)
      expect(instance.path).to eq(path)
    end

    it "sets bucket instance variable as S3 bucket with id" do
      instance = subject.new(id, path)

      expect(instance.bucket).to be_an AWS::S3::Bucket
      expect(instance.bucket.name).to eq('id')
    end
  end

  describe "clear" do
    let(:num_object_in_path) { 100 }
    it "deletes all objects for a path" do
      filtered_object_collection = double()
      filtered_object_collection
        .should_receive(:delete_all)

      s3_object_collection = double()
      s3_object_collection
        .should_receive(:with_prefix)
        .with(path)
        .and_return(filtered_object_collection)

      s3_bucket = double()
      s3_bucket.should_receive(:objects).and_return(s3_object_collection)

      AWS::S3.any_instance.stub(:buckets).and_return({ id => s3_bucket })

      instance = subject.new(id, path)
      instance.clear
    end
  end

  describe "put(id, data)" do
    it "sets bucket path/id content data" do
      s3_object_collection = double()
      s3_object_collection.should_receive(:write).with(:data, { :content_type => 'foo/bar', :metadata=>{} })

      s3_bucket = double()
      s3_bucket.should_receive(:objects).and_return(
        {
          "path/id" => s3_object_collection
        }
      )

      AWS::S3.any_instance.stub(:buckets).and_return({ id => s3_bucket })
      instance = subject.new(id, path)

      instance.put(id, data, 'foo/bar')
    end
  end

  describe "get(id)" do
    it "gets bucket path/id content data" do
      s3_object_collection = double()
      s3_object_collection.should_receive(:read).and_return("content")
      s3_object_collection.should_receive(:content_type).and_return("foo/bar")

      s3_bucket = double()
      s3_bucket.should_receive(:objects).and_return(
        {
          "path/id" => s3_object_collection
        }
      )

      AWS::S3.any_instance.stub(:buckets).and_return({ id => s3_bucket })

      instance = subject.new(id, path)
      object_hash = instance.get(id)

      expected_hash = {
        :content      => "content",
        :content_type => "foo/bar"
      }

      expect(object_hash).to eq(expected_hash)
    end
  end
end

