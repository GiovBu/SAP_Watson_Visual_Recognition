# SAP_Watson_Visual_Recognition
Sample program for calling the Bluemix Watson Visual Recognition Service from SAP using ABAP
--------------------------------------------------------------------------------------------

This sample code calls Watson Visual Recognition from ABAP, calling the server name "gateway-a.watsonplatform.net", adjust proxy if necessary and save the pic "pic_apple.jpg" in directory /tmp on your application server.

You must build the ABAP structure according to the JSON structure that the Watson service returns, check the service API documentation.
The API documentation also tells you how the POST request must look like. With the Visual Recognition service it's not that trivial, because you need a multipart request to send information about the classifiers as JSON and the picture that is classified as binary, see attached example (program name "ZWVISUALRBATCH").

SUGGESTED DOCUMENT AND CONFIGURATION STEPS IN SAP ENVIRONMENT



Following this documentation it will also be possible to implement calls to other Watson services from SAP as the Natural Language Identifier for text analysis.

