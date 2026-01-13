module Router #(
        parameter FLIT_SIZE       = 18,
        parameter MAX_PACKET_SIZE = 64,
        parameter NOC_LENGTH      = 4,
        parameter NOC_WIDTH       = 4,
        parameter ROUTER_ID       = 0

    ) (
        clk, rst,
        in_ports,
        out_ports
    );
    input    clk, rst;
    ReqAckIO in_ports  [0:4];
    ReqAckIO out_ports [0:4];

    localparam  X_ADDRESS_WIDTH     = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH     = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;

    wire [TOTAL_ADDRESS_WIDTH-1:0] buffer_dests          [0:4];
    wire [2:0]                     buffer_port_out_dests [0:4];

    ReqAckIO buffer_out_rack[5]();
    ReqGntIO buf_switch_io[5]();

    Buffer #(
               .DATA_WIDTH      	(FLIT_SIZE          ),
               .MAX_PACKET_SIZE 	(MAX_PACKET_SIZE    ),
               .ADDRESS_SIZE    	(TOTAL_ADDRESS_WIDTH))
           u_Buffer(
               .clk  	(clk         ),
               .rst  	(rst         ),
               .in      (in_ports       ),
               .out     (buffer_out_rack),
               .swicth_allocator_io (buf_switch_io[0:4]),
               .dest 	(buffer_dests)
           );

    Routing_Unit #(
                     .NOC_LENGTH (NOC_LENGTH),
                     .NOC_WIDTH  (NOC_WIDTH ),
                     .ROUTER_ID  (ROUTER_ID )
                 ) routing_unit (
                     .dest_addr  (buffer_dests         ),
                     .port_sel   (buffer_port_out_dests)
                 );

    Allocator switch_allocator (
                  .clk           (clk),
                  .rst           (rst),
                  .buffers_rg    (buf_switch_io),
                  .buffers_dport (buffer_port_out_dests)
              );

    logic [4:0] buffer_grants;
    genvar g;
    generate
        for (g = 0; g < 5; g++) begin : GEN_GRANT_MAP
            assign buffer_grants[g] = buf_switch_io[g].grant;
        end
    endgenerate

    Switch #(
               .DATA_WIDTH(FLIT_SIZE)
           ) switch (
               .buffer_grants  (buffer_grants),
               .dests          (buffer_port_out_dests),
               .buffers_rack_io(buffer_out_rack),
               .outs_rack_io   (out_ports));

endmodule
