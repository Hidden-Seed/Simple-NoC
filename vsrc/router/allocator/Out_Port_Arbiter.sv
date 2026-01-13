// LOCAL > WEST > NORTH > EAST > SOUTH
module Out_Port_Arbiter #(
        parameter PORT_ADDRESS = 0
    )(
        clk, rst,
        buffer_req,
        buffer_dport,
        buffer_grant
    );

    input              clk, rst;
    input        [4:0] buffer_req;
    input        [2:0] buffer_dport [0:4];
    output logic [4:0] buffer_grant;

    logic       current_request;
    logic [2:0] select_current_request;

    integer i;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            buffer_grant <= 5'b0;
            select_current_request <= 3'b111;
        end

        else if(!current_request) begin
            buffer_grant <= 5'b0;

            for(i=0; i<5; i=i+1) begin
                if(buffer_req[i] && buffer_dport[i] == PORT_ADDRESS) begin
                    buffer_grant[i] <= 1'b1;
                    select_current_request <= i;
                    break;
                end
            end
        end
    end

    assign current_request = (select_current_request == 3'b111) ? 1'b0 :
           buffer_req[select_current_request];
endmodule
