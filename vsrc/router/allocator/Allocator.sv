module Allocator(
        clk, rst,
        buffers_rg,
        buffers_dport
    );
    input          clk, rst;
    ReqGntIO       buffers_rg    [0:4];
    input    [2:0] buffers_dport [0:4];

    wire  [4:0] grants      [0:4];
    logic [4:0] buffers_req;
    genvar i, j;

    generate
        for(i = 0; i < 5; i++) begin
            assign buffers_req[i] = buffers_rg[i].req;
        end
    endgenerate

    generate
        for(i = 0; i < 5; i++) begin
            Out_Port_Arbiter #(
                                 .PORT_ADDRESS 	(i)
                             ) u_Out_Port_Arbiter(
                                 .clk          	(clk           ),
                                 .rst          	(rst           ),
                                 .buffer_req   	(buffers_req   ),
                                 .buffer_dport 	(buffers_dport ),
                                 .buffer_grant 	(grants[i]     ));
        end
    endgenerate

    generate
        for (i = 0; i < 5; i++) begin : GEN_BUF_GRANT
            logic [4:0] grant_col;

            for (j = 0; j < 5; j++) begin : GEN_COLLECT
                assign grant_col[j] = grants[j][i];
            end

            assign buffers_rg[i].grant = |grant_col;
        end
    endgenerate
endmodule
