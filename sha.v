/* 
 * Do not change Module name 
*/
module main;
    reg clock;
    reg reset;
    
    wire [7:0] founds1;
    wire [7:0] founds2;

    reg [31:0] data;

    wire mode;

    wire [9:0] count;

    bitcoin_hash_array #(.CORE_COUNT(8)) bha0 (clock, reset, data, 0, founds1);
    bitcoin_hash_array #(.CORE_COUNT(8)) bha1 (clock, reset, data, 1, founds2);

    

    always #5 clock = ~clock;

    initial begin
    
        clock <= 0;
        reset <= 0;

        /*rpre_hash <= 256'h7a78da2dcd5bce692f56a9da07e86e372d2810a016e669ba05c567139524c593;
        
        rmerkle <= 32'hf1fc122b;
        rb_time <= 32'hc7f5d74d;
        rbits <= 32'hf2b9441a;
        nonce <= 32'h42a14696;*/
        
        //Bring the reset line up
        #1 reset <= 1;

        #1 reset <= 0;

        //Load the 32-bit top of the merkle hash
        data <= 32'hf1fc122b;

        // Load the 32-bit time
        #10 data <= 32'hc7f5d74d;

        // Load the bits
        #10 data <= 32'hf2b9441a;

        //Load the 256-bit pre hash
        #10 data <= 32'h9524c593;

        #10 data <= 32'h05c56713;

        #10 data <= 32'h16e669ba;

        #10 data <= 32'h2d2810a0;

        #10 data <= 32'h07e86e37;

        #10 data <= 32'h2f56a9da;

        #10 data <= 32'hcd5bce69;

        #10 data <= 32'h7a78da2d;

        #10

        // Input the nonce
        data <= 32'h42a14694 - 24;

        #1270 $display("%d %b %b", count, founds1, founds2);

        data <= 32'h42a14694 - 8;

        #1280 $display("%d %b %b", count, founds1, founds2);
    
    
        $finish ;
    end
endmodule

// A bank of bitcoin_hash_cores which calculate the hash of sequential nonces in parallel.
// The array uses a vector of BUS_WIDTH to load the data in parallel.
// On reset, 22 words must be clocked into the device. These represent the block-specific data.
// Before the 128-clock pulses, the nonce must be clocked in.
module bitcoin_hash_array
    #(parameter CORE_COUNT = 1 //Number of bitcoin_hash_cores
      )  

    (input clock,
    input reset,
    input [31:0] parallel_data,
    input [7:0] nonce_scalar, //(as a power of 2) This scalar is used to allow the chaining of multiple bitcoin_hash_array modules on the same line, and ensuring each core gets its own nonce. The nonce used in the hash is calculated as nonce = GLOBAL_NONCE +  (CORE_COUNT * nonce_scalar) + NONCE_OFFSET. This of this as like an I2C address
    output [CORE_COUNT-1:0] founds
    //output [31:0] nonce,
    );

    // Calculate the array_witdh - Value used to allow multiple arrays to be chained together on the same bus.
    // Eacharray is given a nonce_scalar. 
    wire [31:0] array_width;

    assign array_width = CORE_COUNT * nonce_scalar;

    //State module. Outputs 0 if in initial mode, and 1 if in loop mode
    wire mode;

    array_state as0 (clock, reset, mode);

    // Block shift register
    wire [255:0] pre_hash;

    wire [31:0] merkle;
    wire [31:0] b_time;
    wire [31:0] bits;

    block_specific_shift_register bsr0 (parallel_data, ~mode & clock, pre_hash, merkle, b_time, bits);

    // Bitcoin core
    wire [CORE_COUNT-1:0] found_vector;

    wire [255:0] out_hash;

    genvar i;
    generate
        for (i = 0; i < CORE_COUNT; i = i + 1) begin : bitcoin_core_generate
            bitcoin_hash_core #(.NONCE_OFFSET(i)) bhc0 (pre_hash, merkle, b_time, bits, parallel_data, array_width, mode & clock, reset, found_vector[i], out_hash);
        end
    endgenerate

    assign founds = found_vector;

    // Reduce the found status of each core
    //assign found = |found_vector;

endmodule

module block_specific_shift_register(
    input [31:0] parallel_data, 
    input clock, 
    output  [255:0] pre_hash,
    output  [31:0] merkle,
    output  [31:0] b_time,
    output  [31:0] bits);

    reg [351:0] block_data;

    always @ (posedge clock) begin
        block_data = { block_data[319:0], parallel_data };
    end

    assign merkle = block_data[32 * 10 +: 32];
    assign b_time = block_data[32 * 9 +: 32];
    assign bits = block_data[32 * 8 +: 32];

    assign pre_hash = { block_data[32 * 0 +: 32], block_data[32 * 1 +: 32], block_data[32 * 2 +: 32], block_data[32 * 3 +: 32], block_data[32 * 4 +: 32], block_data[32 * 5 +: 32], block_data[32 * 6 +: 32], block_data[32 * 7 +: 32]  };

endmodule   

module array_state(input clock, input reset, output loop_or_not_intial);

    reg [4:0] count;

    /*always @ (negedge clock) begin
        if (count != 11) 
            count = count + 1;
    end

    always @ (posedge reset) begin         
        count <= 0;
    end*/

    always @ (negedge clock or posedge reset) begin
        if (reset == 1'b1)
            count <= 0;

        if (clock == 1'b0)
            if (count != 11) 
                count <= count + 1;
    end

    assign loop_or_not_intial = count == 11;

endmodule

// Input the pre hash (just the hash of the first sha block of the bitcoin block) and the remaining data and 128 clock cycles later output whether we have a suitable nonce
module bitcoin_hash_core
                #(parameter NONCE_OFFSET = 0)

                (input [255:0] pre_hash,
                input [31:0] merkle,
                input [31:0] b_time,
                input [31:0] bits,
                input [31:0] nonce,
                input [31:0] array_width, // nonce_scalar * CORE_COUNT. Used to calculate the nonce for a specific core. 
                input clock,
                input reset,
                output found,
                output [255:0] o_hash
                );

    // 7-bit counter
    wire [6:0] count;

    counter #(.N(7)) ct0 (.clock(clock), .reset(reset), .cnt(count));

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

    word_selector ws0 (calculated_hash, merkle, b_time, bits, nonce + array_width + NONCE_OFFSET, count, word);

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

    assign o_hash = _output_hash;

endmodule

//Convert the 4-byte floating point target into a 256-bit integer target. See https://en.bitcoin.it/wiki/Target and https://learnmeabitcoin.com/technical/bits for more info
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
            correct_word cw0 (in[32 * i +: 32], out[32 * i +: 32]);
        end
    endgenerate

endmodule

// N-bit counter
module counter
    #(parameter N = 0)

    (input clock,
    input reset,
    output reg [N-1:0] cnt);
                
    always @ (negedge clock or posedge reset) begin 
        if (reset == 1'b1)
            cnt = 0;
        
        else
            cnt <= cnt + 1;
    end
                
endmodule

// Select a word from the two 512-bit blocks
module word_selector(input [255:0] first_hash,
                    input [31:0] merkle,
                    input [31:0] b_time,
                    input [31:0] bits,
                    input [31:0] nonce,
                    input [6:0] count,
                    output [31:0] word);

    assign word = count == 0 ? merkle : 
                    //First block (for the first SHA digest) hashes the block header
                    (count == 1 ? b_time : 
                    (count == 2 ? bits : 
                    (count == 3 ? nonce : 
                    (count == 4 ? 32'h80000000 : 
                    (count >= 5 && count <= 14 ? 0 : 
                    (count == 15 ? 32'h00000280 : 

                    // Second block (for the second SHA digest) hashes the previous digest
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
    
    counter #(.N(6)) ct0 (.clock(clock), .reset(reset), .cnt(index));
                    
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

    // Extension/block - If we need words w[0..15] then we select get them from the 512-bit block. Otherwise we use the value from the extend_logic module

    assign selected_word = index < 16 ? block : extension;
        
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
    
    // Digest selector - The first hash used in compression is the initial hash. After this we use the generated hash (rolling hash)

    assign compress_hash = index == 0 ? initial_hash : stored_hash;

    //Add the hash generated by the rounds to the input hash

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1)  begin : sum_generate
            assign calculated_hash[32 * i +: 32] = compressed_hash[32 * i +: 32] + initial_hash[32 * i +: 32];
        end
    endgenerate
                        
endmodule

// Stores the rolling 256-bit hash
module rolling_hash(input clock,
                    input reset,
                    input [255:0] in_hash,
                    output reg [255:0] out_hash);
                    
    always @ (posedge clock or posedge reset) begin 
        if (reset == 1'b1)
            out_hash <= 0;

        if (clock == 1'b1)
            out_hash <= in_hash;
    end
                    
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
    
    assign output_hash = { g, f, e, d + temp1, c, b, a, temp1 + temp2 };
                        
endmodule

//Use index to select from one of the 64 SHA256 round constants
//Node: This would be implemented as a simple lookup-table (6-bit input, 32-bit output)
module constants(input [5:0] index,
                 output [31:0] constant);
					  
	wire [2047:0] k;
		
	assign k = 2048'hc67178f2bef9a3f7a4506ceb90befffa8cc7020884c8781478a5636f748f82ee682e6ff35b9cca4f4ed8aa4a391c0cb334b0bcb52748774c1e376c0819a4c116106aa070f40e3585d6990624d192e819c76c51a3c24b8b70a81a664ba2bfe8a192722c8581c2c92e766a0abb650a735453380d134d2c6dfc2e1b213827b70a851429296706ca6351d5a79147c6e00bf3bf597fc7b00327c8a831c66d983e515276f988da5cb0a9dc4a7484aa2de92c6f240ca1cc0fc19dc6efbe4786e49b69c1c19bf1749bdc06a780deb1fe72be5d74550c7dc3243185be12835b01d807aa98ab1c5ed5923f82a459f111f13956c25be9b5dba5b5c0fbcf71374491428a2f98;
    
    assign constant = k[32 * index +: 32];
        
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
    always @ (posedge clock or posedge reset) begin
        if (reset == 1'b1)
            m_register <= 0;
        
        if (clock == 1'b1)
            m_register <= { m_register[479:0], word };
    end
    
    // Output the 4 values (w[i-2], w[i-7], w[i-15] and w[i-16])
    assign m2 = m_register[1 * 32 +: 32];
    assign m7 = m_register[6 * 32 +: 32];
    assign m15 = m_register[14 * 32 +: 32];
    assign m16 = m_register[15 * 32 +: 32];

endmodule