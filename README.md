# SAP_Watson_Visual_Recognition
Sample program for calling the Bluemix Watson Visual Recognition Service from SAP using ABAP
--------------------------------------------------------------------------------------------

This sample code calls Watson Visual Recognition from ABAP, calling the server name "gateway-a.watsonplatform.net", adjust proxy if necessary and save the pic "pic_apple.jpg" in directory /tmp on your application server.

You must build the ABAP structure according to the JSON structure that the Watson service returns (check the service API documentation).
The API documentation also tells you how the POST request must look like. With the Visual Recognition service it's not that trivial, because you need a multipart request to send information about the classifiers as JSON and the picture that is classified as binary. See attached ABAP code as example (program name "ZWVISUALRBATCH").

:pencil: **CONFIGURATION STEPS**

1) Create in Bluemix the Watson Service. In this case the "Visual Recognition" Service and get the credentials.

2) Get certificate for Bluemix Server accessing url https://gateway.watsonplatform.net/.

3) Install Certificate in the SAP System by calling the STRUST transaction.

:warning: **TROUBLESHOOTING**

Calling a Watson service in Bluemix from within a SAP system may fail for various reasons. Following some symptoms and how to proceed if you are experiencing those.

**- GET or POST method throws exception Communication Error**

- Verify that the specified host name is correct.

- Check proxy server settings.

**- HTTP status is 400 (Bad Request)**

- Check uri path and parameter string. Pay attention to lower and upper cases.

**- HTTP status is 401 (Unauthorized)**

- Check that user name and password as specified in your program matches those of your service instance
in Bluemix.

**- HTTP status is 403 (Forbidden)**

- Check if the SSL certificate for the Bluemix server is installed correctly. Call SMICM transaction.

Following this documentation it will also be possible to implement calls to other Watson services from SAP as the Natural Language Classifier (NLC) for text analysis.

:book: **SUGGESTED DOCUMENTATION**

[Hands-on_Call_Watson_from_SAP](https://www.ibm.com/developerworks/community/files/form/anonymous/api/library/25ecde0d-ebfb-47d4-a379-a048a1ccea57/document/d7c30a1b-da62-4066-b4b5-aedc92dfb139/media/Hands-on_Call_Watson_from_SAP_20171009.pdf).

[Building Cognitive Applications with IBM Watson Services: Getting Started](http://www.redbooks.ibm.com/redbooks/pdfs/sg248387.pdf).

[Building Cognitive Applications with IBM Watson Services: Visual Recognition](http://www.redbooks.ibm.com/redbooks/pdfs/sg248393.pdf).
