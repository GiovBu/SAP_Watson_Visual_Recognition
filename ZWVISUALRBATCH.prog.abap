*&---------------------------------------------------------------------*
*& Report ZWVISUALRBATCH
*&---------------------------------------------------------------------*
report zwvisualrbatch.


start-of-selection.

  constants:
    gc_host          type string value 'https://access.alche**api.com',
    gc_apikey        type string value '05e2a461fa1899**52899e3f7a57f9ccc**d949c',
    gc_path          type string value '/visual-recognition/api/v3/classify',
    gc_proxy_host    type string value '',
    gc_proxy_service type string value ''.


  data:
    lv_base64     type string,
    lv_subtype(4) type c value is initial,
    lv_msg        type string.


  data:
    lo_http_client type ref to if_http_client,
    lo_rest_client type ref to cl_rest_http_client,
    lv_uri         type string.

  " create http client instance
  cl_http_client=>create_by_url(
    exporting
      url                = gc_host             " Watson service host (w/o uri path)
      proxy_host         = gc_proxy_host       " proxy server (w/o protocol prefix)
      proxy_service      = gc_proxy_service    " proxy port
*      ssl_id             = 'ANONYM'
    importing
      client             = lo_http_client
    exceptions
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      others             = 4 ).
  if sy-subrc <> 0.
    perform raise_message using 'E' 'Cannot create HTTP client.'. 
  endif.

  " set http protocol version
  lo_http_client->request->set_version( if_http_request=>co_protocol_version_1_1 ).


  " set uri path
  lv_uri = gc_path && `?api_key=` && gc_apikey && `&version=2016-05-20`.
  cl_http_utility=>set_request_uri(
    exporting
      request = lo_http_client->request
      uri     = lv_uri ).

  " create REST client instance from http client instance
  create object lo_rest_client
    exporting
      io_http_client = lo_http_client.


  " build multipart request
  data(lo_request) = lo_rest_client->if_rest_client~create_request_entity( ).
  lo_request->set_content_type( iv_media_type = if_rest_media_type=>gc_multipart_form_data ).

  data:
    lo_part type ref to if_http_entity.

  lo_part = lo_http_client->request->if_http_entity~add_multipart( ).
  lo_part->set_header_field( name ='Content-Disposition' value = 'form-data; name="parameters"' ).
  lo_part->set_header_field( name ='Content-Type' value = if_rest_media_type=>gc_appl_json ).
  lo_part->append_cdata( data = '{ "classifier_ids": ["ModelAll_490560248"] }' ).

  lo_part = lo_http_client->request->if_http_entity~add_multipart( ).
  lo_part->set_header_field( name ='Content-Disposition' value = 'form-data; name="images_file"; filename="pic_lego.jpg"' ).
  lo_part->set_header_field( name ='Content-Type' value = if_rest_media_type=>gc_image_jpeg ).

  " read data from file
  data:
    lt_data        type xstring.

  data(lv_filesrc) = '/tmp/pic_apple.jpg'.
  open dataset lv_filesrc for input in binary mode.
  read dataset lv_filesrc into lt_data.
  data(lv_len) = xstrlen( lt_data ).
  lo_part->set_data( data = lt_data offset = 0 length = lv_len ).
  close dataset lv_filesrc.


  " execute REST POST call
  try.
      lo_rest_client->if_rest_resource~post( lo_request ).
    catch cx_rest_client_exception into data(lo_exception).
      lv_msg = `HTTP POST failed: ` && lo_exception->get_text( ).
      perform raise_message using 'E' lv_msg.               
  endtry.

  " get and check REST call response
  data(lo_response) = lo_rest_client->if_rest_client~get_response_entity( ).
  perform check_response using lo_response.

  " evaluate response data
  " result scheme:
  " { "custom_classes": 0,
  "   "images": [
  "     { "classifiers": [
  "         { "classes": [
  "             { "class": "apple",
  "               "score": 0.562432,
  "               "type_hierarchy": "/fruit/apple"
  "             }
  "           ],
  "           "classifier_id": "default",
  "           "name": "default"
  "         }
  "       ],
  "       "image": "fruitapple.jpg"
  "     }
  "   ],
  "   images_processed": 1
  " }
  types:
    begin of ty_s_class,
      class type string,
      score type p length 12 decimals 6,
    end of ty_s_class,
    ty_t_class type standard table of ty_s_class with non-unique default key.
  types:
    begin of ty_s_classifier,
      classes       type ty_t_class,
      classifier_id type string,
      name          type string,
    end of ty_s_classifier,
    ty_t_classfifier type STANDARD TABLE OF ty_s_classifier with non-unique default key.
  types:
    begin of ty_s_image,
      classifiers type ty_t_classfifier,
      image       type string,
    end of ty_s_image,
    ty_t_image TYPE STANDARD TABLE OF ty_s_image WITH non-unique default key.
  types:
    begin of ty_s_result,
      custom_classes   type i,
      images           type ty_t_image,
      images_processed type i,
    end of ty_s_result.
  data:
    ls_result type ty_s_result.

  data(lv_json_data) = lo_response->get_string_data( ).

  " eliminate 0x000A
  replace all occurrences of cl_abap_char_utilities=>newline in lv_json_data with space.

  " property names must be upper case
  do.
    " the .? in regex makes it non-greedy
    find regex '("[\l\_]+.?":)' in lv_json_data submatches data(lv_prop_lowercase).
    if sy-subrc <> 0. exit. endif.
    data(lv_prop_uppercase) = lv_prop_lowercase.
    translate lv_prop_uppercase to upper case.
    replace all occurrences of lv_prop_lowercase in lv_json_data with lv_prop_uppercase.
  enddo.

  " call json parser (ignore properties that do not exist in abap structure)
  lv_json_data = `{ "RESULT": ` && lv_json_data && `}`.
  call transformation id source xml lv_json_data
                         result     result = ls_result
                         options    value_handling = 'accept_data_loss'.


  " dump result to screen
  read table ls_result-images index 1 into data(ls_image).
  if sy-subrc <> 0.
    write: / 'Picture cannot be classified'.
  else.
    loop at ls_image-classifiers into data(ls_classifier).
      write: / 'Classifier:', at 20 ls_classifier-name.
      loop at ls_classifier-classes into data(ls_class).
        write: / '  Class:', at 15 ls_class-class.
        write: / '  Score:', at 15 ls_class-score.
      endloop.
      skip.
    endloop.
  endif.

  exit.

*&---------------------------------------------------------------------*
*&      Form  check_response
*&---------------------------------------------------------------------*
*       checks the http status of a REST response and issues
*       appropriate message
*----------------------------------------------------------------------*
*      -->IO_RESPONSE      REST response object
*----------------------------------------------------------------------*
form check_response using io_response type ref to if_rest_entity.
  data:
    lv_message type string.
  data(lv_http_status)  = io_response->get_header_field( '~status_code' ).
  data(lv_reason)       = io_response->get_header_field( '~status_reason' ).
  data(lv_content_type) = io_response->get_header_field( 'content-type' ).
  if lv_http_status eq 200.
    " http status 200 = OK
    lv_message = `Data of type ` && lv_content_type && ` received.`. 
    perform raise_message using 'S' lv_message.
  else.
    " http error status
    lv_message = `HTTP status ` && lv_http_status && ` (` && lv_reason && `)`. 
    perform raise_message using 'E' lv_message.
  endif.

endform.                                                " check_response

*&---------------------------------------------------------------------*
*&      Form  raise_message
*&---------------------------------------------------------------------*
*       raises a messages
*----------------------------------------------------------------------*
*      -->IV_MTYPE     message type, e.g. 'E' or 'S'
*      -->IV_MESSAGE   message text
*----------------------------------------------------------------------*
form raise_message using iv_mtype   type sy-msgty
                         iv_message type string.
  message iv_message type iv_mtype.
endform.                                                 " raise_message