# SAP_Watson_Visual_Recognition
Sample program for calling the Bluemix Watson Visual Recognition Service from SAP using ABAP
--------------------------------------------------------------------------------------------

This sample code calls Watson Visual Recognition from ABAP, calling the server name "gateway-a.watsonplatform.net", adjust proxy if necessary and save the pic "pic_apple.jpg" in directory /tmp on your application server.

You must build the ABAP structure according to the JSON structure that the Watson service returns, check the service API documentation.
The API documentation also tells you how the POST request must look like. With the Visual Recognition service it's not that trivial, because you need a multipart request to send information about the classifiers as JSON and the picture that is classified as binary, see attached example (program name "ZWVISUALRBATCH").

**CONFIGURATION STEPS**

1) Create in Bluemix the Watson Service. In this case the "Visual Recognition" Service and get the credentials.

2) Get certificate for Bluemix Server accessing url https://gateway.watsonplatform.net/.

3) Install Certificate in the SAP System by calling the STRUST transaction.

:warning: **TROUBLESHOOTING**
Calling a Watson service in Bluemix from within an SAP system may fail for various reason. The following
describe some symptoms and how to proceed if you are experiencing those.

**- GET or POST method throws exception Communication Error**
• Verify that the specified host name is correct.
• Check proxy server settings.

**- HTTP status is 400 (Bad Request)**
• Check uri path and parameter string. Pay attention to lower and upper cases.

**- HTTP status is 401 (Unauthorized)**
• Check that user name and password as specified in your program matches those of your service instance
in Bluemix.

**- HTTP status is 403 (Forbidden)**
• Procced as follows to check if the SSL certificate for the Bluemix server is installed correctly. Call SMICM transaction.


SUGGESTED DOCUMENT AND CONFIGURATION STEPS IN SAP ENVIRONMENT



Following this documentation it will also be possible to implement calls to other Watson services from SAP as the Natural Language Classifier (NLC) for text analysis.

