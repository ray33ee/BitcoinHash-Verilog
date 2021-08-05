/* 
 * Do not change Module name 
*/
module main;
    
    reg [255:0] in_hash;
    reg [511:0] block;
    reg clock;
    reg reset;
    wire [255:0] out_hash;
    wire [31:0] test;
    
    
    reg [7:0] selector;
    wire [31:0] constant;
    
    constants k1 (.selector(selector), .constant(constant));
    
    process p0 (.in_hash(in_hash), .block(block), .clk(clock), .reset(reset), .out_hash(out_hash), .test(test));
    
    wire [31:0] message;
    
    //serial_compressor sc0 (.block(block), .clk(clock), .reset(reset), .message(message));
    
    always #5 clock = ~clock;

    initial begin
        
        reset <= 0;
        clock <= 0;
        
        block <= 512'h00000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000726C64806F20776F68656C6C;
        in_hash <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
        
        #6 reset <= 1;
        
        #670 $display("%h %h", out_hash, test);
        $display("%d", out_hash[(7 * 32) + 31:(7 * 32) + 0]);
        
        #30 selector <= 18;
        
        # 20 $display("%d", constant);
        
        
        $finish ;
    end
    
endmodule

//Each clock cycle generates a new item in the 64 word extended message
module serial_extender(input [511:0] block,
                        input clk,
                        input reset,
                        output [31:0] message);

    //Working reg stores the last 16 words in the message schedule
    reg [511:0] working_reg;
    
    reg [5:0] counter;
    
    //A word in the block array, indexed by the count
    wire [31:0] selected;
    
    selector512 sel0 (.data(block), .selector(counter), .element(selected));
    
    //A word extended from the working reg
    wire [31:0] extend;
    
    extend s0 (
        .m2(working_reg[1 * 32 + 31:1*32]), 
        .m7(working_reg[6 * 32 + 31:6*32]), 
        .m15(working_reg[14 * 32 + 31:14*32]), 
        .m16(working_reg[15 * 32 + 31:15*32]), 
        .mn(extend));
    
    
    always @ (posedge clk) begin
        // Shift all the 
        working_reg <= {
            working_reg[14 * 32 + 31:14 * 32], 
            working_reg[13 * 32 + 31:13 * 32], 
            working_reg[12 * 32 + 31:12 * 32], 
            working_reg[11 * 32 + 31:11 * 32], 
            working_reg[10 * 32 + 31:10 * 32], 
            working_reg[9 * 32 + 31:9 * 32], 
            working_reg[8 * 32 + 31:8 * 32], 
            working_reg[7 * 32 + 31:7 * 32], 
            working_reg[6 * 32 + 31:6 * 32], 
            working_reg[5 * 32 + 31:5 * 32], 
            working_reg[4 * 32 + 31:4 * 32], 
            working_reg[3 * 32 + 31:3 * 32], 
            working_reg[2 * 32 + 31:2 * 32], 
            working_reg[1 * 32 + 31:1 * 32],
            working_reg[0 * 32 + 31:0 * 32], 
            active};
    
        if (!reset) begin
            counter <= 0;
            working_reg <= 0;
        end
        else
            counter = counter + 1;
            
    end
    
    //Since elements 0-15 in the expanded schedule are just the block, when the count is 0-15 we return
    //'selected'. For 16-63, we use 'extend'
    
    wire [31:0] active;
    
    assign active = counter <= 15 ? selected : extend;
    
               
endmodule

// Takes a 512-bit block of data, and a 256-bit input hash and (after 67 clk cycles) 
// computes the new hash.
module process(input [255:0] in_hash,
                input [511:0] block,
                input clk,
                input reset,
                output [255:0] out_hash,
                output [31:0] test);
                
    // Counter wires
    wire [7:0] compression_counter;
    wire compression_clock;
    wire extender_clock;
    wire load_or_not_process;
    wire setup;
    
    clock_counter c0 (.clk(clk), 
        .reset(reset), 
        .compression_clock(compression_clock), 
        .extender_clock(extender_clock),
        .load_or_not_process(load_or_not_process),
        .setup(setup),
        .cnt(compression_counter));
    
    // Extender
    reg [511:0] block_reg;
    wire [2047:0] extended_schedule;
    
    schedule sh0 (.block(block_reg), .message(extended_schedule));
    
    wire [31:0] m;
    wire [31:0] m0;
    
    always @ (posedge setup) begin
        block_reg <= block;
    end
    
    serial_extender se0 (.block(block_reg), .clk(extender_clock), .reset(reset), .message(m0));
    
    // Schedule selector
    
    selector2048 s0 (.data(extended_schedule), .selector(compression_counter), .element(m));
    
    //Constants wires
    wire [31:0] k;
    
    constants k0 (.selector(compression_counter), .constant(k));
    
    //Compression
    wire [255:0] compression_output;
    
    compression cpr0 (
        .in_hash(in_hash), 
        .load_or_not_process(load_or_not_process),
        .schedule(m),
        .constant(k),
        .clk(compression_clock),
        .out_hash(compression_output));
    
    // Adder
    reg [256:0] digest;
    
    assign out_hash = digest + compression_output;
    
    always @ (posedge setup) begin
        digest <= in_hash;
    end
    
    assign test = m0;
    
    
endmodule

// A module to iteratively apply the compression algorithm to a loaded input hash
module compression( input [255:0] in_hash,
                    input load_or_not_process,
                    input [31:0] schedule,
                    input [31:0] constant,
                    input clk,
                    output reg [255:0] out_hash);

    reg [255:0] _in_hash;
    wire [255:0] _out_w_hash;
    
    compress c0 (.in_hash(_in_hash), .schedule(schedule), .constant(constant), .out_hash(_out_w_hash));
    
    
    always @ (posedge clk) begin
        if (load_or_not_process) begin
            //Load the module input hash into the hash register
            _in_hash <= in_hash;
        end else begin 
            // Load the output from the compress logic into the output register
            out_hash <= _out_w_hash;
        end
    end
    
    always @ (negedge clk) begin
        if (!load_or_not_process) begin
            // Copy the output register to the input register
            _in_hash <= out_hash;
        end 
    end
    
           
endmodule

//Special clock that counts from 0-64 (inclusive) with lines that 
// - feed the compression clock
// - feed the compression load_or_not_process pin
// - feed the register clocks (setup)
module clock_counter(input clk,
                    input reset,
                    output compression_clock,
                    output extender_clock,
                    output load_or_not_process,
                    output setup,
                    output [7:0] cnt);
                    
    reg [7:0] total_output; 

    always @ (posedge clk) begin
        if (!reset)
            total_output <= 0;
        else
            total_output = total_output + 1;
            
        if (total_output == 67)
            total_output <= 0;
            
    end
    
    assign compression_clock = (total_output == 2 || total_output > 3) && clk;
    assign extender_clock = (total_output > 3) && clk;
    assign cnt = total_output < 4 ? 0 : total_output-4;
    assign load_or_not_process = (total_output > 0 && total_output < 4);
    assign setup = total_output == 1 && clk;

endmodule

// Extend the message schedule by a single word
module extend(input [31:0] m2, 
                input [31:0] m7, 
                input [31:0] m15, 
                input [31:0] m16,
                output [31:0] mn);
                
    wire [31:0] s0;
    wire [31:0] s1;

    assign s0 = { m15[6:0], m15[31:7] } ^ { m15[17:0], m15[31:18] } ^ (m15 >> 3);
    assign s1 = { m2[16:0], m2[31:17] } ^ { m2[18:0], m2[31:19] } ^ (m2 >> 10);
    assign mn = m16 + s0 + m7 + s1;

endmodule

// Take one word from the schedule and incorporate it into the hash. (compression)
module compress(input [255:0] in_hash,
                input [31:0] schedule,
                input [31:0] constant,
                output [255:0] out_hash);
                
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] c;
    wire [31:0] d;
    wire [31:0] e;
    wire [31:0] f;
    wire [31:0] g;
    wire [31:0] h;
    
    wire [31:0] S1;
    wire [31:0] ch;
    wire [31:0] temp1;
    wire [31:0] S0;
    wire [31:0] maj;
    wire [31:0] temp2;
    
    wire [31:0] test;

    assign a = in_hash[31:0];
    assign b = in_hash[63:32];
    assign c = in_hash[95:64];
    assign d = in_hash[127:96];
    assign e = in_hash[159:128];
    assign f = in_hash[191:160];
    assign g = in_hash[223:192];
    assign h = in_hash[255:224];
    
    assign S1 = { e[5:0], e[31:6] } ^ { e[10:0], e[31:11] } ^ { e[24:0], e[31:25] };
    assign ch = (e & f) ^ (~e & g);
    assign temp1 = h + S1 + ch + schedule + constant;
    
    assign S0 = { a[1:0], a[31:2] } ^ { a[12:0], a[31:13] } ^ { a[21:0], a[31:22] };
    assign maj = (a & b) ^ (a & c) ^ (b & c);
    assign temp2 = S0 + maj;
    
    assign test = S1;
    
    assign out_hash = { g, f, e, d + temp1, c, b, a, temp1 + temp2 };
       
endmodule

module constants(input [7:0] selector,
                 output [31:0] constant);

    localparam logic [2047:0] k =  2048'hc67178f2bef9a3f7a4506ceb90befffa8cc7020884c8781478a5636f748f82ee682e6ff35b9cca4f4ed8aa4a391c0cb334b0bcb52748774c1e376c0819a4c116106aa070f40e3585d6990624d192e819c76c51a3c24b8b70a81a664ba2bfe8a192722c8581c2c92e766a0abb650a735453380d134d2c6dfc2e1b213827b70a851429296706ca6351d5a79147c6e00bf3bf597fc7b00327c8a831c66d983e515276f988da5cb0a9dc4a7484aa2de92c6f240ca1cc0fc19dc6efbe4786e49b69c1c19bf1749bdc06a780deb1fe72be5d74550c7dc3243185be12835b01d807aa98ab1c5ed5923f82a459f111f13956c25be9b5dba5b5c0fbcf71374491428a2f98;
    
    selector2048 s0 (.data(k), .selector(selector), .element(constant));
        
endmodule

module selector2048(input [2047:0] data,
                        input [7:0] selector,
                        output [31:0] element
                        );

    assign element = {  data[selector * 32 + 31],
                        data[selector * 32 + 30],
                        data[selector * 32 + 29],
                        data[selector * 32 + 28],
                        data[selector * 32 + 27],
                        data[selector * 32 + 26],
                        data[selector * 32 + 25],
                        data[selector * 32 + 24],
                        data[selector * 32 + 23],
                        data[selector * 32 + 22],
                        data[selector * 32 + 21],
                        data[selector * 32 + 20],
                        data[selector * 32 + 19],
                        data[selector * 32 + 18],
                        data[selector * 32 + 17],
                        data[selector * 32 + 16],
                        data[selector * 32 + 15],
                        data[selector * 32 + 14],
                        data[selector * 32 + 13],
                        data[selector * 32 + 12],
                        data[selector * 32 + 11],
                        data[selector * 32 + 10],
                        data[selector * 32 + 9],
                        data[selector * 32 + 8],
                        data[selector * 32 + 7],
                        data[selector * 32 + 6],
                        data[selector * 32 + 5],
                        data[selector * 32 + 4],
                        data[selector * 32 + 3],
                        data[selector * 32 + 2],
                        data[selector * 32 + 1],
                        data[selector * 32 + 0]  };
               
endmodule

module selector512(input [511:0] data,
                        input [5:0] selector,
                        output [31:0] element
                        );

    assign element = {  data[selector * 32 + 31],
                        data[selector * 32 + 30],
                        data[selector * 32 + 29],
                        data[selector * 32 + 28],
                        data[selector * 32 + 27],
                        data[selector * 32 + 26],
                        data[selector * 32 + 25],
                        data[selector * 32 + 24],
                        data[selector * 32 + 23],
                        data[selector * 32 + 22],
                        data[selector * 32 + 21],
                        data[selector * 32 + 20],
                        data[selector * 32 + 19],
                        data[selector * 32 + 18],
                        data[selector * 32 + 17],
                        data[selector * 32 + 16],
                        data[selector * 32 + 15],
                        data[selector * 32 + 14],
                        data[selector * 32 + 13],
                        data[selector * 32 + 12],
                        data[selector * 32 + 11],
                        data[selector * 32 + 10],
                        data[selector * 32 + 9],
                        data[selector * 32 + 8],
                        data[selector * 32 + 7],
                        data[selector * 32 + 6],
                        data[selector * 32 + 5],
                        data[selector * 32 + 4],
                        data[selector * 32 + 3],
                        data[selector * 32 + 2],
                        data[selector * 32 + 1],
                        data[selector * 32 + 0]  };
               
endmodule

// Take a 512 bit input block and extend it to 2048 bits
module schedule(input [511:0] block,
            output [2047:0] message);

        //Copy the first 16 words to the message schedule
        assign message[511:0] = block[511:0];
        
        //Extend the first 16 words to the remaining 48 words
        generate
        genvar i;
            for (i = 16; i < 64; i = i + 1) begin
                extend ex16 (.m2(message[(i - 2) * 32 + 31:(i - 2) * 32 + 0]), 
                            .m7(message[(i - 7) * 32 + 31:(i - 7) * 32 + 0]), 
                            .m15(message[(i - 15) * 32 + 31:(i - 15) * 32 + 0]), 
                            .m16(message[(i - 16) * 32 + 31:(i - 16) * 32 + 0]), 
                            .mn(message[(i) * 32 + 31:(i) * 32 + 0]));
            end
        endgenerate
        
   
endmodule