module Switch_Allocator(
        clk, rst,
        buffers_rg,
        buffers_dport
    );
    input clk, rst;
    ReqGntIO buffers_rg [0:4];
    input [2:0] buffers_dport [0:4];
    wire [4:0] grants [0:4];

    generate;
        genvar i;

        for(i = 0; i < 5; i++) begin
            Out_Port_Arbiter #(.PORT_ADDRESS 	(i))
                             u_Out_Port_Arbiter(
                                 .clk          	(clk            ),
                                 .rst          	(rst            ),
                                 .buffer_req   	(buffer_req[i]  ),
                                 .buffer_dport 	(buffer_dport[i]),
                                 .buffer_grant 	(grants[i]      ));

            assign buffers_rg[i].grant = |{grants[i]};
        end
    endgenerate
endmodule
