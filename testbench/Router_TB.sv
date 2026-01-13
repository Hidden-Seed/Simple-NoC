`define ROUTER_ID  4'b1001
`define NOC_WIDTH  4
`define NOC_HEIGHT 4

module Router_TB();
    logic clk = 0, rst = 0;

    ReqAckVif vio_i_ports[5];
    ReqAckVif vio_o_ports[5];

    ReqAckIO i_ports[5]();
    ReqAckIO o_ports[5]();

    semaphore in_keys [5];
    semaphore out_keys [5];

    logic [4:0] init_done;
    generate
        genvar i;
        for(i = 0; i < 5; i++) begin
            initial begin
                vio_i_ports[i] = new(i_ports[i]);
                vio_o_ports[i] = new(o_ports[i]);
                init_done[i]   = 1'b1;
            end
        end
    endgenerate

    Router #(.ROUTER_ID(`ROUTER_ID)
            ) DUT (
               .clk      (clk),
               .rst      (rst),
               .in_ports (i_ports),
               .out_ports(o_ports));

    task automatic random_packet_trafficing(input int number_of_iters);
        begin
            for(int i = 0; i < number_of_iters; i++) begin

                int rand_port = $urandom_range(5);
                int packet_size = ($urandom_range(64) + 3) % 64;
                packet new_packet = generate_packet(4, 4, `ROUTER_ID, packet_size);

                string packet_info = packet_details(new_packet);

                $display("%d\n", rand_port);
                $display("%s", packet_info);

                vio_i_ports[rand_port].handshake_send_packet(clk, new_packet, packet_size);
            end
        end
    endtask

    task automatic send_packet_from_port(input int port_num);
        begin
            int packet_size = ($urandom_range(64) + 3) % 64;
            packet new_packet = generate_packet(`NOC_WIDTH, `NOC_HEIGHT, `ROUTER_ID, packet_size);
            packet received_packet;

            string packet_info = packet_details(new_packet);

            int dest = packet_routing_port(new_packet[0][3:0], `ROUTER_ID);
            $display("%sSource Port: %0d\nDest Port  : %0d", packet_info, port_num, dest);

            fork
                begin
                    in_keys[port_num].get();
                    vio_i_ports[port_num].handshake_send_packet(clk, new_packet, packet_size);
                    in_keys[port_num].put();
                end

                begin
                    out_keys[dest].get();
                    vio_o_ports[dest].handshake_receive_packet(clk, received_packet);
                    out_keys[dest].put();
                end
            join

            if(packets_cmp(new_packet, received_packet, packet_size)) begin
                $display("Packet ID %0d received succeesfully with no errors", new_packet[0][15:8]);
            end
            else begin
                $error("Sent and received packages are not the same");
                for(int j = 0; j < packet_size; j++)
                    $display("s : %b, r : %b", new_packet[j], received_packet[j]);
            end
        end
    endtask

    `GENERATE_CLOCK(clk, 10);

    initial begin
        wait(&init_done);

        for(int i = 0; i < 5; i++)  begin
            in_keys[i]  = new(1);
            out_keys[i] = new(1);

            vio_i_ports[i].io.req  = 0;
            vio_i_ports[i].io.data = 0;
            vio_o_ports[i].io.ack  = 0;
        end

        #0 rst  = 1'b1;
        #20 rst = 1'b0;

        $display("Initialization done");
        #50 fork
             for (int i = 0; i < 5; i++) begin
                 automatic int port = i;
                 repeat(4) send_packet_from_port(port);
             end
         join
         #1000 $finish();
    end

    initial begin
        $fsdbDumpfile("Router.fsdb");
        $fsdbDumpvars(0, Router_TB, "+mda");
    end
endmodule
