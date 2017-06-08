# S3 java sdk demo

注意aws-java-sdk使用1.8.11版本


```
package com.opscloud.tutorial;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.Protocol;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.*;
import com.amazonaws.util.IOUtils;
import com.amazonaws.util.StringUtils;
import com.amazonaws.services.s3.transfer.TransferManager;
import com.amazonaws.services.s3.transfer.Upload;
import com.amazonaws.AmazonClientException;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.io.PrintWriter;

public class CephS3Tutorial {
    // Please change it in your testing environment
    private static String objectFilePathForTesting = "/tmp/test.txt";

    public static void main(String[] args) throws Exception {
        String accessKey = "xxx";
        String secretKey = "xxx";

        ClientConfiguration clientConfig = new ClientConfiguration();
        clientConfig.setProtocol(Protocol.HTTP);

        AWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
        AmazonS3 conn = new AmazonS3Client(credentials, clientConfig);
        conn.setEndpoint("10.10.10.20:7480");

        uploadMultipart(conn);

//        propareFile();
//        listBucketsAndObjects(conn);

    }

    public static void uploadMultipart(AmazonS3 conn) throws InterruptedException {
        String bucketName = "test_lifecycle";
        String objectName = "multipart-test-" + UUID.randomUUID().toString();
        String filePath = "/tmp/bigfile.data";

        TransferManager tm = new TransferManager(conn);
        Upload upload = tm.upload(bucketName, objectName, new File(filePath));

        try {
            // Or you can block and wait for the upload to finish
            upload.waitForCompletion();
            System.out.println("Upload complete.");
            tm.shutdownNow();
        } catch (AmazonClientException amazonClientException) {
            System.out.println("Unable to upload file, upload was aborted.");
            amazonClientException.printStackTrace();
        }

    }

    public static void propareFile() throws IOException {
        try{
            PrintWriter writer = new PrintWriter(objectFilePathForTesting, "UTF-8");
            writer.println("The first line");
            writer.println("The second line");
            writer.close();
        } catch (IOException e) {
            throw e;
        }
    }

    public static void createBucketAndObjects(AmazonS3 conn) throws IOException {
        String uuid = UUID.randomUUID().toString();
        String bucketName = "my-new-bucket-" + uuid;
        // 1. create bucket
        Bucket bucket = conn.createBucket(bucketName);
        System.out.println("bucket created with name: " + bucket.getName());

        // 2. put object in bucket
        String objectName = "object-" + UUID.randomUUID().toString();
        byte[] contentBytes = IOUtils.toByteArray(new FileInputStream(new File(objectFilePathForTesting)));
        Long contentLength = Long.valueOf(contentBytes.length);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(contentBytes);

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(contentLength);

        conn.putObject(bucket.getName(), objectName, byteArrayInputStream, metadata);

        // 3. GENERATE OBJECT DOWNLOAD URLS
        GeneratePresignedUrlRequest request = new GeneratePresignedUrlRequest(bucket.getName(), objectName);
        System.out.println("download url is:  " + conn.generatePresignedUrl(request));

        // 4. list bucket and object
        listBucketsAndObjects(conn);

        // 5. delete created object
        // conn.deleteObject(bucket.getName(), objectName);

        // 6. delete bucket(bucket must be empty)
        // conn.deleteBucket(bucket.getName());
    }

    public static void listBucketsAndObjects(AmazonS3 conn) {
        System.out.println("\n===========list buckets and objects");
        List<Bucket> buckets = conn.listBuckets();
        for (Bucket bucket : buckets) {
            System.out.println(bucket.getName() + "\t" +
                    StringUtils.fromDate(bucket.getCreationDate()));

            ObjectListing objects = conn.listObjects(bucket.getName());
            do {
                for (S3ObjectSummary objectSummary : objects.getObjectSummaries()) {
                    System.out.println("\t\t" + objectSummary.getKey() + "\t" +
                            objectSummary.getSize() + "\t" +
                            StringUtils.fromDate(objectSummary.getLastModified()));
                }
                objects = conn.listNextBatchOfObjects(objects);
            } while (objects.isTruncated());

        }
    }


}





```

