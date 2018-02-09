@Grapes(
    @Grab(group='com.amazonaws', module='aws-java-sdk-s3', version='1.11.273')
)

import groovy.io.FileType
import com.amazonaws.ClientConfiguration
import com.amazonaws.services.s3.AmazonS3
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.model.Bucket
import com.amazonaws.services.s3.model.PutObjectRequest
import com.amazonaws.auth.AWSStaticCredentialsProvider
import com.amazonaws.services.s3.model.CannedAccessControlList
import com.amazonaws.regions.Regions
import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.model.ListObjectsV2Result
import com.amazonaws.services.s3.model.S3ObjectSummary
import java.util.List

AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
    .withRegion(Regions.EU_CENTRAL_1 )
    //.withClientConfiguration(config)
    //.withForceGlobalBucketAccessEnabled(true)
    .build()

for (Bucket bucket : s3Client.listBuckets()) {
    println " - " + bucket.getName()
}
def input_file_list = new File('cloud-optimized-geotiffs.txt')

ListObjectsV2Result result = s3Client.listObjectsV2("geotiff-cloud")
List<S3ObjectSummary> objects = result.getObjectSummaries()
for (S3ObjectSummary os : objects) {
    System.out.println("* " + os.getKey())
    if (os.getKey()[-3..-1] == "tif") {

        s3Client.setObjectAcl("geotiff-cloud", os.getKey(), CannedAccessControlList.PublicRead)
        input_file_list << "/vsicurl/http://geotiff-cloud.s3-website.eu-central-1.amazonaws.com/" + os.getKey() + "\n"
    }

}