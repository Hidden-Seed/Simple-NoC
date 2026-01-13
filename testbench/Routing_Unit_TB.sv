module Routing_Unit_TB();
    logic [3:0] dest     [0:4];
    logic [2:0] port_out [0:4];

    localparam ROUTER_ID = 4'b1001; // (x,y)=(1,2)

    Routing_Unit #(
                     .NOC_WIDTH  (4        ),
                     .NOC_LENGTH (4        ),
                     .ROUTER_ID  (ROUTER_ID)
                 ) DUT (
                     .dest_addr(dest    ),
                     .port_sel (port_out));

    // L W N E S
    // Cases for testing:
    //    0  1  2  3  4  x
    // 0  1  2  3  3  3
    // 1  1  2  3  3  3
    // 2  1  0  3  3  3
    // 3  1  4  3  3  3
    // 4  1  4  3  3  3
    // y

    function automatic logic [2:0] lookup_table(
        input int y,
        input int x
    );
        logic [2:0] table [0:4][0:4];

        begin
            table = '{
                '{1,2,3,3,3},
                '{1,2,3,3,3},
                '{1,0,3,3,3},
                '{1,4,3,3,3},
                '{1,4,3,3,3}
            };
            lookup_table = table[y][x];
        end
    endfunction
    
    integer i, j;
    initial begin
        int         x, y;
        logic [2:0] expected_port;

        for(i = 0; i < 5; i++)
            dest[i] = 4'd0;
        $display("Router id (x, y) = (%0d, %0d)", ROUTER_ID[1:0], ROUTER_ID[3:2]);

        for(i = 0; i < 16; i++) begin
            j       = 1;
            dest[j] = i;

            x = dest[j][1:0];
            y = dest[j][3:2];
            expected_port = lookup_table(y, x);
            
            #4;
            if(port_out[j] != expected_port) begin
                $write("[ERROR ] ");
            end
            else begin
                $write("[Passed] ");
            end
            $display("dest[%0d]=%2d (x=%0d,y=%0d) expected=%0d actual=%0d",
                    j, dest[j], x, y, expected_port, port_out[j]);
            #37;
        end
        #300 $finish();
    end

    initial begin
        $fsdbDumpfile("Routing_Unit.fsdb");
        $fsdbDumpvars(0, Routing_Unit_TB, "+mda");
    end
endmodule
