module Buffer #(
        parameter DATA_WIDTH      = 18,
        parameter MAX_PACKET_SIZE = 64,
        parameter ADDRESS_SIZE    = 4
    ) (
        clk, rst,
        in , out,
        swicth_allocator_io,
        dest
    );
    input    clk, rst                 ;
    ReqAckIO in                  [0:4];
    ReqAckIO out                 [0:4];
    ReqGntIO swicth_allocator_io [0:4];
    output [ADDRESS_SIZE-1:0] dest [0:4];

    generate;
        genvar i;

        for(i = 0; i < 5; i++) begin
            Buffer_Unit #(
                            .DATA_WIDTH      	(DATA_WIDTH     ),
                            .MAX_PACKET_SIZE 	(MAX_PACKET_SIZE),
                            .ADDRESS_SIZE    	(ADDRESS_SIZE   ))
                        u_Buffer_Unit(
                            .clk  	(clk   ),
                            .rst  	(rst   ),
                            .in     (in[i]  ),
                            .out    (out[i] ),
                            .swicth_allocator_io(swicth_allocator_io[i]),
                            .dest 	(dest[i]  )
                        );
        end
    endgenerate
endmodule
