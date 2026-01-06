// request-acknowledge handshaking mechanism
// synchronous communication between modules
interface ReqAckIO #(
        parameter DATA_WIDTH = 18
    )();
    logic [DATA_WIDTH-1:0] data;
    logic req;
    logic ack;

    // master mode
    modport master (output data, req, input ack);
    // slave mode
    modport slave  (input data, req, output ack);
endinterface
