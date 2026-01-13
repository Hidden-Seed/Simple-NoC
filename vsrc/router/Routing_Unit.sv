module Routing_Unit #(
        parameter NOC_WIDTH  = 4,
        parameter NOC_LENGTH = 4,
        parameter ROUTER_ID  = 0
    )(
        dest_addr,
        port_sel
    );
    localparam  X_ADDRESS_WIDTH = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;

    input  [TOTAL_ADDRESS_WIDTH-1:0] dest_addr [0:4];
    output [2:0]                     port_sel  [0:4];

    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : GEN_PORT_DECODER
            Port_Decoder #(
                             .NOC_LENGTH (NOC_LENGTH),
                             .NOC_WIDTH  (NOC_WIDTH),
                             .ROUTER_ID  (ROUTER_ID)
                         ) u_port_decoder (
                             .dest_address (dest_addr[i]),
                             .port_address (port_sel[i])
                         );
        end
    endgenerate
endmodule
