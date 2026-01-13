module Switch #(
        parameter DATA_WIDTH = 18
    )(
        buffer_grants,
        dests,
        buffers_rack_io,
        outs_rack_io
    );
    input    [4:0] buffer_grants;  // specifies which of 5 buffers has the permission to start a data transfer
    input    [2:0] dests           [0:4];
    ReqAckIO       buffers_rack_io [0:4];
    ReqAckIO       outs_rack_io    [0:4];

    wire [4:0] buffers_ack [0:4];

    generate
        genvar i;
        for(i = 0; i < 5; i++) begin
            logic [4:0] grants_out;

            // assign grants_out = `BIT_EXTEND((dests[i] == i), 5) & buffer_grants;
            assign grants_out = {{dests[4] == i}, {dests[3] == i}, {dests[2] == i}, {dests[1] == i}, {dests[0] == i}} & buffer_grants;
            // assign buffers_rack_io[i].ack = buffers_ack[i];

            assign buffers_rack_io[i].ack = |{buffers_ack[0][i], buffers_ack[1][i], buffers_ack[2][i], buffers_ack[3][i], buffers_ack[4][i]};
            Switch_Multiplexer #(
                                   .DATA_WIDTH(DATA_WIDTH)
                               ) sw_mux_out (
                                   .grants          (grants_out     ),
                                   .buffers_rack_io (buffers_rack_io       ),
                                   .out_rack_io     (outs_rack_io[i]       ),
                                   .buffers_ack     (buffers_ack[i] ));
        end

    endgenerate

endmodule
