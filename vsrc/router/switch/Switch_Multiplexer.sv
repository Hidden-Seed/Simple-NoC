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
    input [4:0] grants;
    ReqAckIO buffers_rack_io[0:4];
    ReqAckIO out_rack_io;
    output [4:0] buffers_ack;

    logic [2:0] buffer_number;
    logic       port_busy;

    // decoding one-hot grants to a single number
    always_comb begin
        casex (grants)
            5'bxxxx1 : begin
                buffer_number = 0;
            end
            5'bxxx1x : begin
                buffer_number = 1;
            end
            5'bxx1xx : begin
                buffer_number = 2;
            end
            5'bx1xxx : begin
                buffer_number = 3;
            end
            5'b1xxxx : begin
                buffer_number = 4;
            end
        endcase
    end

    assign port_busy = |{grants};

    assign out_rack_io.req = port_busy ?
           ((buffer_number == 0) ? buffers_rack_io[0].req :
            (buffer_number == 1) ? buffers_rack_io[1].req :
            (buffer_number == 2) ? buffers_rack_io[2].req :
            (buffer_number == 3) ? buffers_rack_io[3].req :
            (buffer_number == 4) ? buffers_rack_io[4].req : 1'bz) : 1'bz;

    assign out_rack_io.data = port_busy ?
           ((buffer_number == 0) ? buffers_rack_io[0].data :
            (buffer_number == 1) ? buffers_rack_io[1].data :
            (buffer_number == 2) ? buffers_rack_io[2].data :
            (buffer_number == 3) ? buffers_rack_io[3].data :
            (buffer_number == 4) ? buffers_rack_io[4].data : `BIT_EXTEND(1'bz, DATA_WIDTH)
           ) : `BIT_EXTEND(1'bz, DATA_WIDTH);

    generate
        genvar i;
        for(i = 0; i < 5; i++) begin
            assign buffers_ack[i] = (port_busy & (buffer_number == i)) ? out_rack_io.ack : 1'bz;
        end
    endgenerate
endmodule
