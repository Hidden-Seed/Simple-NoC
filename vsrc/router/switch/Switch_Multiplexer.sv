// single multiplexer on each out port
// priority-based arbitration mechanism
// prioritizing in this order: local, west, north, east, and south ports 
module Switch_Multiplexer #(
        parameter DATA_WIDTH = 18
    )(
        grants,
        buffers_rack_io,
        out_rack_io,
        buffers_ack
    );
    input        [4:0] grants;
    ReqAckIO           buffers_rack_io [0:4];
    ReqAckIO           out_rack_io;
    output logic [4:0] buffers_ack;

    logic [4:0]            in_req;
    logic [DATA_WIDTH-1:0] in_data [0:4];

    // unpack interface → wires
    genvar g;
    generate
        for (g = 0; g < 5; g++) begin
            assign in_req[g]  = buffers_rack_io[g].req;
            assign in_data[g] = buffers_rack_io[g].data;
        end
    endgenerate

    always_comb begin
        out_rack_io.req  = 1'b0;
        out_rack_io.data = '0;
        buffers_ack      = '0;

        for (int i = 0; i < 5; i++) begin
            if (grants[i]) begin
                out_rack_io.req  = in_req[i];
                out_rack_io.data = in_data[i];
                buffers_ack[i]   = out_rack_io.ack;
                break; // priority: low index first
            end
        end
    end
endmodule
