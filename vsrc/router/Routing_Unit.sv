module Routing_Unit #(
        parameter NOC_WIDTH  = 4,
        parameter NOC_LENGTH = 4,
        parameter ROUTER_ID  = 0
    )(
        dest_local, dest_west,  dest_north,  dest_east, dest_south,
        port_local, port_west, port_north, port_east, port_south
    );
    localparam  X_ADDRESS_WIDTH = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;

    input  [TOTAL_ADDRESS_WIDTH-1 : 0] dest_local, dest_west,  dest_north,  dest_east, dest_south;
    output [2:0] port_local, port_west, port_north, port_east, port_south;


    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                 lcoal_port_decoder (.dest_address(dest_local), .port_address(port_local));


    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                 west_port_decoder (.dest_address(dest_west), .port_address(port_west));


    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                 north_port_decoder (.dest_address(dest_north), .port_address(port_north));


    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                 east_port_decoder (.dest_address(dest_east), .port_address(port_east));


    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                 south_port_decoder (.dest_address(dest_south), .port_address(port_south));

endmodule
