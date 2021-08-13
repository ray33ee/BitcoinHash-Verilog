/* 
 * Do not change Module name 
*/
module main;

    reg clock;
    reg reset;
    
    reg [511:0] block;
    reg [255:0] initial_hash;
    
    wire [255:0] calculated_hash;
    
    wire [31:0] selected;

    wire [5:0] cnt;
    wire [6:0] cnt2;
    
    counter c0 (.clock(clock), .reset(reset), .cnt(cnt));
    counter_7 c1 (.clock(clock), .reset(reset), .cnt(cnt2));
    
    block_selector bs0 (.block(block), .index(cnt[3:0]), .item(selected));
    
    sha256_round sha0 (
        .clock(clock),
        .reset(reset),
        .block(selected),
        .initial_hash(initial_hash),
        .calculated_hash(calculated_hash));

    reg [31:0] merkle;
    reg [31:0] b_time;
    reg [31:0] bits;
    reg [31:0] nonce;

    wire [31:0] word;

    word_selector ws0 (initial_hash, merkle, b_time, bits, nonce, cnt2, word);

    wire found;
    wire [255:0] bc_hash;

    bitcoin bc0 (initial_hash, merkle, b_time, bits, nonce, clock, reset, found, bc_hash);
        
    always #5 clock = ~clock;

    initial begin
    
        clock <= 0;
        reset <= 0;
        
        block <= 512'h00000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000726C64806F20776F68656C6C;
        initial_hash <= 256'h7a78da2dcd5bce692f56a9da07e86e372d2810a016e669ba05c567139524c593;

        merkle <= 32'hf1fc122b;
        b_time <= 32'hc7f5d74d;
        bits <= 32'hf2b9441a;
        nonce <= 32'h42a14696;
        
        #1 reset <= 1;

        $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, bc_hash);
        
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h %d", cnt2, word, bc_hash, found);

        nonce <= 32'h42a14695;

        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, bc_hash);
        
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h", cnt2, word, word);
        #10 $display("%d %d %h %d", cnt2, word, bc_hash, found);
        
        /*$display("%h decimal: %d", calculated_hash, calculated_hash[0 * 32 + 31:0 * 32 + 0]);
        #10 $display("%h decimal: %d", calculated_hash, calculated_hash[0 * 32 + 31:0 * 32 + 0]);
        #10 $display("%h decimal: %d", calculated_hash, calculated_hash[0 * 32 + 31:0 * 32 + 0]);
        #10 $display("%h decimal: %d", calculated_hash, calculated_hash[0 * 32 + 31:0 * 32 + 0]);
        
        
        #600 $display("%h decimal: %d", calculated_hash, calculated_hash[0 * 32 + 31:0 * 32 + 0]);*/
    
    
        $finish ;
    end
endmodule

// Input the pre hash (just the hash of the first sha block of the bitcoin block) and the remaining data and 128 clock cycles later output whether we have a suitable nonce
module bitcoin(input [255:0] pre_hash,
                input [31:0] merkle,
                input [31:0] b_time,
                input [31:0] bits,
                input [31:0] nonce, //global nonce + nonce offset
                input clock,
                input reset,
                output found,
                output [255:0] final_hash);

    // 7-bit counter
    wire [6:0] count;

    counter_7 ct0 (.clock(clock), .reset(reset), .cnt(count));

    // Register storing the hash generated by the first digest
    reg [255:0] calculated_hash;

    always @ (posedge clock) begin 
        if (count == 63) begin
            calculated_hash <= output_hash;
        end
    end

    // The input hash for the sha digest. For the first digest this is the prehash, for the second this is the default SHA256 hash
    wire [255:0] sha_input_hash;

    assign sha_input_hash = count < 64 ? pre_hash : 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;

    // Block word
    wire [31:0] word;

    word_selector ws0 (calculated_hash, merkle, b_time, bits, nonce, count, word);

    // SHA rounds
    wire [255:0] output_hash;

    sha256_round sr0 (clock, reset, word, sha_input_hash, output_hash);

    // Float to int
    wire [255:0] target;

    float_target_to_int fti0 (bits, target);

    //Corect the endianness of the output
    wire [255:0] _output_hash;

    correct_endianness ce0 (output_hash, _output_hash);

    //Compare the outputted hash with the target
    assign found = count == 127 && _output_hash <= target;

    assign final_hash = _output_hash;

endmodule

//Convert the 4-byte floating point target into a 256-bit integer target
module float_target_to_int(input [31:0] float_target,
                            output [255:0] int_target);
              
    wire [7:0] exponent;
    wire [23:0] mantissa;

    assign exponent = float_target[7:0];
    assign mantissa = { float_target[15:8], float_target[23:16], float_target[31:24] };

    assign int_target = (mantissa << ((exponent - 3) * 8));
   
endmodule

//The endianness of the logic_sha256 module is not quite right. So until we figure out out, we just use this module to correct it
module correct_word(input [31:0] in,
                    output [31:0] out);

    assign out = { in[7:0], in[15:8], in[23:16], in[31:24] };

endmodule

module correct_endianness(input [255:0] in,
                            output [255:0] out);
    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : correct_generate
            correct_word cw0 (in[i * 32 + 31:i*32], out[i * 32 + 31:i*32]);
        end
    endgenerate

endmodule

// 7-bit counter
module counter_7(input clock,
                input reset,
                output reg [6:0] cnt);
                
    always @ (negedge clock) begin 
        if (!reset)
            cnt <= 0;
        else
            cnt = cnt + 1;
    end
                
endmodule

module word_selector(input [255:0] first_hash,
                    input [31:0] merkle,
                    input [31:0] b_time,
                    input [31:0] bits,
                    input [31:0] nonce,
                    input [6:0] count,
                    output [31:0] word);

    assign word = count == 0 ? merkle : 
                    (count == 1 ? b_time : 
                    (count == 2 ? bits : 
                    (count == 3 ? nonce : 
                    (count == 4 ? 32'h80000000 : 
                    (count >= 5 && count <= 14 ? 0 : 
                    (count == 15 ? 32'h00000280 : 

                    (count >= 64 && count <= 7+64 ? first_hash[32 * (count-64) +: 32] : 
                    (count == 8+64 ? 32'h80000000 : 
                    (count >= 9+64 && count <= 14+64 ? 0 : 
                    (count == 15+64 ? 32'h00000100 : 0))))))))));

endmodule

//Module FSM representing a single round of (of 64) of the SHA-256 algorithm. This includes expansion (if round number is greater than 16) and compression into an input hash.
//A note about the clock: The rising edge a) shifts the extender shifter and b) stores the outputted hash into the intermediate hash storage. The falling edge incremements the counter
module sha256_round(input clock,
                    input reset,
                    input [31:0] block,
                    input [255:0] initial_hash,
                    output [255:0] calculated_hash);
                    
    // Counter
    wire [5:0] index;
    
    counter ct0 (.clock(clock), .reset(reset), .cnt(index));
                    
    // Shift register
    wire [31:0] selected_word;
    
    wire [31:0] m2;
    wire [31:0] m7;
    wire [31:0] m15;
    wire [31:0] m16;
    
    extender_shifter exs0 (
        .word(selected_word), 
        .clock(clock), 
        .reset(reset), 
        .m2(m2), 
        .m7(m7), 
        .m15(m15), 
        .m16(m16));
        
    // Extension logic
    wire [31:0] extension;
    
    extension_logic el0 (
        .m2(m2),
        .m7(m7),
        .m15(m15),
        .m16(m16),
        .extension(extension));
        
    // Block selecter
    
    //wire [31:0] block_word;
    
    //block_selector bs0 (.block(block), .index(index[3:0]), .item(block_word));
    
    // Extension/block
    
    extension_selector es0 (
        .extended(extension), 
        .selected(block), 
        .index(index), 
        .choice(selected_word));
        
    // Constants
    
    wire [31:0] constant;
    
    constants con0 (.index(index), .constant(constant));
    
    // Compression logic
    
    wire [255:0] compress_hash;
    wire [255:0] compressed_hash;
    
    compression_logic cmp0 (
        .m(selected_word), 
        .k(constant), 
        .input_hash(compress_hash), 
        .output_hash(compressed_hash));
    
    // Rolling hash
    
    wire [255:0] stored_hash;
    
    rolling_hash rh0 (
        .clock(clock), 
        .reset(reset), 
        .in_hash(compressed_hash),
        .out_hash(stored_hash));
    
    // Digest selector 
    
    digest_selector ds0 (
        .initial_hash(initial_hash), 
        .rolling_hash(stored_hash), 
        .index(index), 
        .hash(compress_hash));
        
    assign calculated_hash[32 * 0 +: 32] = compressed_hash[32 * 0 +: 32] + initial_hash[32 * 0 +: 32];
    assign calculated_hash[32 * 1 +: 32] = compressed_hash[32 * 1 +: 32] + initial_hash[32 * 1 +: 32];
    assign calculated_hash[32 * 2 +: 32] = compressed_hash[32 * 2 +: 32] + initial_hash[32 * 2 +: 32];
    assign calculated_hash[32 * 3 +: 32] = compressed_hash[32 * 3 +: 32] + initial_hash[32 * 3 +: 32];
    assign calculated_hash[32 * 4 +: 32] = compressed_hash[32 * 4 +: 32] + initial_hash[32 * 4 +: 32];
    assign calculated_hash[32 * 5 +: 32] = compressed_hash[32 * 5 +: 32] + initial_hash[32 * 5 +: 32];
    assign calculated_hash[32 * 6 +: 32] = compressed_hash[32 * 6 +: 32] + initial_hash[32 * 6 +: 32];
    assign calculated_hash[32 * 7 +: 32] = compressed_hash[32 * 7 +: 32] + initial_hash[32 * 7 +: 32];


                        
endmodule

// Stores the rolling 256-bit hash
module rolling_hash(input clock,
                    input reset,
                    input [255:0] in_hash,
                    output reg [255:0] out_hash);
                    
    always @ (posedge clock) begin 
        if (!reset)
            out_hash <= 0;
        else
            out_hash = in_hash;
    end
                    
endmodule

// 6-bit counter
module counter(input clock,
                input reset,
                output reg [5:0] cnt);
                
    always @ (negedge clock) begin 
        if (!reset)
            cnt <= 0;
        else
            cnt = cnt + 1;
    end
                
endmodule

// The first hash used in compression is the initial hash. After this we use the generated hash (rolling hash)
module digest_selector(input [255:0] initial_hash,
                        input [255:0] rolling_hash,
                        input [5:0] index,
                        output [255:0] hash);
                        
    assign hash = index == 0 ? initial_hash : rolling_hash;
                        
endmodule
                        

// Complete one round of compression using the input hash, expanded message schedule array and the round constants 
module compression_logic(input [31:0] m,
                        input [31:0] k,
                        input [255:0] input_hash,
                        output [255:0] output_hash);
         
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

    assign a = input_hash[31:0];
    assign b = input_hash[63:32];
    assign c = input_hash[95:64];
    assign d = input_hash[127:96];
    assign e = input_hash[159:128];
    assign f = input_hash[191:160];
    assign g = input_hash[223:192];
    assign h = input_hash[255:224];
    
    assign S1 = { e[5:0], e[31:6] } ^ { e[10:0], e[31:11] } ^ { e[24:0], e[31:25] };
    assign ch = (e & f) ^ (~e & g);
    assign temp1 = h + S1 + ch + m + k;
    
    assign S0 = { a[1:0], a[31:2] } ^ { a[12:0], a[31:13] } ^ { a[21:0], a[31:22] };
    assign maj = (a & b) ^ (a & c) ^ (b & c);
    assign temp2 = S0 + maj;
    
    assign test = S1;
    
    assign output_hash = { g, f, e, d + temp1, c, b, a, temp1 + temp2 };
                        
endmodule

//Use index to select from one of the 64 SHA256 round constants
//Node: This would be implemented as a simple lookup-table (6-bit input, 32-bit output)
// Todo: Find a less cumbersome way to do this
module constants(input [5:0] index,
                 output [31:0] constant);
					  
		wire [2047:0] k;
		
		assign k = 2048'hc67178f2bef9a3f7a4506ceb90befffa8cc7020884c8781478a5636f748f82ee682e6ff35b9cca4f4ed8aa4a391c0cb334b0bcb52748774c1e376c0819a4c116106aa070f40e3585d6990624d192e819c76c51a3c24b8b70a81a664ba2bfe8a192722c8581c2c92e766a0abb650a735453380d134d2c6dfc2e1b213827b70a851429296706ca6351d5a79147c6e00bf3bf597fc7b00327c8a831c66d983e515276f988da5cb0a9dc4a7484aa2de92c6f240ca1cc0fc19dc6efbe4786e49b69c1c19bf1749bdc06a780deb1fe72be5d74550c7dc3243185be12835b01d807aa98ab1c5ed5923f82a459f111f13956c25be9b5dba5b5c0fbcf71374491428a2f98;
    
    //localparam logic [2047:0] k =  2048'hc67178f2bef9a3f7a4506ceb90befffa8cc7020884c8781478a5636f748f82ee682e6ff35b9cca4f4ed8aa4a391c0cb334b0bcb52748774c1e376c0819a4c116106aa070f40e3585d6990624d192e819c76c51a3c24b8b70a81a664ba2bfe8a192722c8581c2c92e766a0abb650a735453380d134d2c6dfc2e1b213827b70a851429296706ca6351d5a79147c6e00bf3bf597fc7b00327c8a831c66d983e515276f988da5cb0a9dc4a7484aa2de92c6f240ca1cc0fc19dc6efbe4786e49b69c1c19bf1749bdc06a780deb1fe72be5d74550c7dc3243185be12835b01d807aa98ab1c5ed5923f82a459f111f13956c25be9b5dba5b5c0fbcf71374491428a2f98;
    
    assign constant = k[32 * index +: 32];

    /*assign constant = { k[index * 32 + 31],
                    k[index * 32 + 30],
                    k[index * 32 + 29],
                    k[index * 32 + 28],
                    k[index * 32 + 27],
                    k[index * 32 + 26],
                    k[index * 32 + 25],
                    k[index * 32 + 24],
                    k[index * 32 + 23],
                    k[index * 32 + 22],
                    k[index * 32 + 21],
                    k[index * 32 + 20],
                    k[index * 32 + 19],
                    k[index * 32 + 18],
                    k[index * 32 + 17],
                    k[index * 32 + 16],
                    k[index * 32 + 15],
                    k[index * 32 + 14],
                    k[index * 32 + 13],
                    k[index * 32 + 12],
                    k[index * 32 + 11],
                    k[index * 32 + 10],
                    k[index * 32 + 9],
                    k[index * 32 + 8],
                    k[index * 32 + 7],
                    k[index * 32 + 6],
                    k[index * 32 + 5],
                    k[index * 32 + 4],
                    k[index * 32 + 3],
                    k[index * 32 + 2],
                    k[index * 32 + 1],
                    k[index * 32 + 0]};*/
        
endmodule

// Use an index to select an element in an array of 64 lots of 32-bit words
// Todo: Find a less cumbersome way to do this
module block_selector(input [511:0] block,
                        input [3:0] index,
                        output [31:0] item);

    assign item = block[32 * index +: 32];
         
    /*assign item = { block[index * 32 + 31],
                    block[index * 32 + 30],
                    block[index * 32 + 29],
                    block[index * 32 + 28],
                    block[index * 32 + 27],
                    block[index * 32 + 26],
                    block[index * 32 + 25],
                    block[index * 32 + 24],
                    block[index * 32 + 23],
                    block[index * 32 + 22],
                    block[index * 32 + 21],
                    block[index * 32 + 20],
                    block[index * 32 + 19],
                    block[index * 32 + 18],
                    block[index * 32 + 17],
                    block[index * 32 + 16],
                    block[index * 32 + 15],
                    block[index * 32 + 14],
                    block[index * 32 + 13],
                    block[index * 32 + 12],
                    block[index * 32 + 11],
                    block[index * 32 + 10],
                    block[index * 32 + 9],
                    block[index * 32 + 8],
                    block[index * 32 + 7],
                    block[index * 32 + 6],
                    block[index * 32 + 5],
                    block[index * 32 + 4],
                    block[index * 32 + 3],
                    block[index * 32 + 2],
                    block[index * 32 + 1],
                    block[index * 32 + 0]};*/
                        
endmodule

// If we need words w[0..15] then we select get them from the 512-bit block. Otherwise we use the value from the extend_logic module 
module extension_selector(input [31:0] extended,
                            input [31:0] selected,
                            input [5:0] index,
                            output [31:0] choice);
         
    assign choice = index < 16 ? selected : extended; 
                            
endmodule

// Logic to extend the last 16 words into a 17th
module extension_logic(input [31:0] m2,
                        input [31:0] m7,
                        input [31:0] m15,
                        input [31:0] m16,
                        output [31:0] extension);

    wire [31:0] s0;
    wire [31:0] s1;

    assign s0 = { m15[6:0], m15[31:7] } ^ { m15[17:0], m15[31:18] } ^ (m15 >> 3);
    assign s1 = { m2[16:0], m2[31:17] } ^ { m2[18:0], m2[31:19] } ^ (m2 >> 10);
    
    assign extension = m16 + s0 + m7 + s1;
               
endmodule

// 16x32-bit shift register exposing words at positions 1, 6, 15 and 16 (for w[i-2], w[i-7], w[i-15] and w[i-16], respectively)
module extender_shifter(input [31:0] word,
                        input clock,
                        input reset,
                        output [31:0] m2,
                        output [31:0] m7,
                        output [31:0] m15,
                        output [31:0] m16);

    // 512-bit register containing the last 16 values in the message extension algorithm
    reg [511:0] m_register;

    // Shift the values by one word and insert the input word at the beginning
    always @ (posedge clock) begin
        if (!reset)
            m_register <= 0;
        else begin
            m_register <= { m_register[479:0], word };
        end
    end
    
    // Output the 4 values (w[i-2], w[i-7], w[i-15] and w[i-16])
    assign m2 = m_register[1 * 32 + 31:1 * 32];
    assign m7 = m_register[6 * 32 + 31:6 * 32];
    assign m15 = m_register[14 * 32 + 31:14 * 32];
    assign m16 = m_register[15 * 32 + 31:15 * 32];

endmodule