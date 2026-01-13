`define DATA_WIDTH     18
`define MAX_PACKET_NUM 64

module Buffer_Unit_TB();
    logic clk = 0, rst = 0;

    ReqAckIO #(.DATA_WIDTH(`DATA_WIDTH)) buffer_in();
    ReqAckIO #(.DATA_WIDTH(`DATA_WIDTH)) buffer_out();
    ReqGntIO sw_all_io();

    Buffer_Unit #(
                    .DATA_WIDTH          (`DATA_WIDTH    ),
                    .MAX_PACKET_SIZE     (`MAX_PACKET_NUM)
                ) DUT (
                    .clk                 (clk       ),
                    .rst                 (rst       ),
                    .in                  (buffer_in.slave  ),
                    .out                 (buffer_out.master),
                    .swicth_allocator_io (sw_all_io        ));

    always #5 clk = ~clk;

    initial begin
        #0 buffer_out.ack = 0;
        buffer_in.req     = 0;
        buffer_in.data    = 0;
        sw_all_io.grant   = 0;

        rst = 1;
        #17 rst = 0;

        #54 @(posedge clk);
        $display("Start sending data");
        buffer_in.req  = 1'b1;
        buffer_in.data = 18'd347;
        wait(buffer_in.ack == 1'b1);
        buffer_in.req = 1'b0;

        #100 $finish();
    end

    initial begin
        $fsdbDumpfile("Buffer_Unit.fsdb");
        $fsdbDumpvars(0, Buffer_Unit_TB);
    end
endmodule
