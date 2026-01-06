interface ReqGntIO();
    logic req;
    logic grant;

    modport slave  (input req, output grant);
    modport master (output req, input grant);
endinterface
