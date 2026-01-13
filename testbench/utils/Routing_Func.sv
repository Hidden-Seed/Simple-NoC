function automatic int packet_routing_port (
    input logic [3:0] dest, 
    input logic [3:0] router_id
    );
    int router_x = router_id[1:0];
    int router_Y = router_id[3:2];
    int dest_x   = dest[1:0];
    int dest_y   = dest[3:2];

    if(dest_x == router_x && dest_y == router_Y)
        return `LOCAL_PORT_ID;
    else if (dest_x > router_x)
        return `EAST_PORT_ID;
    else if (dest_x < router_x)
        return `WEST_PORT_ID;
    else if (dest_y < router_Y)
        return `NORTH_PORT_ID;
    else
        return `SOUTH_PORT_ID;
endfunction

function automatic logic [`ADDR_WIDTH-1:0] convert_coor_to_packet_adr(input int x, int y);
    localparam X_WIDTH = $clog2(`NOC_WIDTH);
    localparam Y_WIDTH = $clog2(`NOC_HEIGHT);
    return {y[Y_WIDTH-1:0], x[X_WIDTH-1:0]};
endfunction

function automatic logic [`ADDR_WIDTH-1:0] generate_random_address(input int noc_max_x, int noc_max_y);
    int x = $random % noc_max_x;
    int y = $random % noc_max_y;

    return convert_coor_to_packet_adr(x, y);
endfunction

function automatic packet generate_packet(input int noc_max_x, int noc_max_y, int current_id, int packet_size);
    packet      new_packet;
    logic [3:0] dest_id;
    int         rnd = $urandom;

    for(int i = 0; i < 63; i++) begin
        new_packet[i] = 0;
    end

    // source address doesn't matter
    new_packet[0][7:4] = current_id;

    // generating destination address for the packet
    dest_id = generate_random_address(noc_max_x, noc_max_y);

    while (dest_id == current_id) begin
        dest_id = generate_random_address(noc_max_x, noc_max_y);
    end

    new_packet[0][3:0]   = dest_id;
    new_packet[0][17:16] = `FLIT_HEADER;
    // random packet number
    new_packet[0][15:8]  = (rnd + (rnd >> 8) + current_id) & 8'hFF;
    
    new_packet[1] = packet_size; // embedding packet size in the payload for debugging
    // random packet payload :
    for(int i = 2; i < packet_size; i++) begin
        new_packet[i] = $urandom_range($time) & {2'b00, {16{1'b1}}};  // the and operation is for taking care of flit type bits to be 00 (payload type)
    end
    
    new_packet[packet_size-1][17:16] = `FLIT_TAIL;

    return new_packet;
endfunction

function automatic string packet_details(packet pkt);
    string result = "";
    $timeformat(-9, 0, " ns", 0);
    $sformat(result, "%sTime       : %0t\n", result, $time);
    $sformat(result, "%sPacket ID  : %0d\n", result, pkt[0][15:8]);
    $sformat(result, "%sSource Addr: (%0d, %0d)\n", result, pkt[0][5:4], pkt[0][7:6]);
    $sformat(result, "%sDest Addr  : (%0d, %0d)\n", result, pkt[0][1:0], pkt[0][3:2]);
    $sformat(result, "%sSize       : %0d\n", result, pkt[1]);
    
    return result;
endfunction

function int packets_cmp(packet x1, packet x2, int size);
    for(int i = 0; i < size; i++) begin
        if(x1[i] != x2[i])
            return 0;
    end
    return 1;
endfunction
