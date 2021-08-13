/* 
 * Do not change Module name 
 module bitcoin_test(input [255:0] in_hash,
                    input [31:0] hash_merkle, //Last (or first depending on endianness) word of merkle hash
                    input [31:0] block_time,
                    input [31:0] bits,
                    input [31:0] nonce,
                    output found,
                    output [511:0] test);
*/
module main;

    //The hash for the first block of the first sha digest
    reg [255:0] in_hash;
    reg [31:0] merkle;
    reg [31:0] block_time;
    reg [31:0] bits;
    reg [31:0] nonce;

    wire found;
    wire [255:0] bitcoin_hash;


    bitcoin_test bt0 (in_hash, merkle, block_time, bits, nonce, found, bitcoin_hash);

    wire [255:0] target;

    float_target_to_int fti0 (bits, target);

    initial  begin
    
        in_hash <= 256'h7a78da2dcd5bce692f56a9da07e86e372d2810a016e669ba05c567139524c593;
        merkle <= 32'hf1fc122b;
        block_time <= 32'hc7f5d74d;
        bits <= 32'hf2b9441a;
        nonce <= 32'h42a14695;

        #20 
        $display("Hash  : %h", bitcoin_hash);
        $display("Target: %h", target);
        $display("Result: %s (%b)", found ? "Nonce found" : "Incorrect nonce", found);

        if (found) begin
            $display("Nonce: %h %d", nonce, nonce);    
        end
        
    end
endmodule

// Logic to extend the last 16 words into a 17th
module extend_word(input [31:0] w2,
                        input [31:0] w7,
                        input [31:0] w15,
                        input [31:0] w16,
                        output [31:0] extension);

    wire [31:0] s0;
    wire [31:0] s1;

    assign s0 = { w15[6:0], w15[31:7] } ^ { w15[17:0], w15[31:18] } ^ (w15 >> 3);
    assign s1 = { w2[16:0], w2[31:17] } ^ { w2[18:0], w2[31:19] } ^ (w2 >> 10);
    
    assign extension = w16 + s0 + w7 + s1;
               
endmodule
                        

// Complete one round of compression using the input hash, expanded message schedule array and the round constants 
module compression_round(input [31:0] w,
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
    assign temp1 = h + S1 + ch + w + k;
    
    assign S0 = { a[1:0], a[31:2] } ^ { a[12:0], a[31:13] } ^ { a[21:0], a[31:22] };
    assign maj = (a & b) ^ (a & c) ^ (b & c);
    assign temp2 = S0 + maj;
    
    assign output_hash = { g, f, e, d + temp1, c, b, a, temp1 + temp2 };
                        
endmodule

// Take a 512 bit input block and extend it to 2048 bits
module extend_message(input [511:0] block,
            output [2047:0] message);

        //Copy the first 16 words to the message schedule
        assign message[511:0] = block[511:0];
        
        //Extend the first 16 words to the remaining 48 words
        genvar i;
        generate
            for (i = 16; i < 64; i = i + 1) begin : extend_generate
                extend_word el1 (.w2(message[(i - 2) * 32 + 31:(i - 2) * 32 + 0]), 
                                    .w7(message[(i - 7) * 32 + 31:(i - 7) * 32 + 0]), 
                                    .w15(message[(i - 15) * 32 + 31:(i - 15) * 32 + 0]), 
                                    .w16(message[(i - 16) * 32 + 31:(i - 16) * 32 + 0]), 
                                    .extension(message[(i) * 32 + 31:(i) * 32 + 0]));
            end
        endgenerate
        
   
endmodule

module compression(input [2047:0] w,
                    input [255:0] in_hash,
                    output [255:0] out_hash);
                     
    // Space for 64 hashes (one input hash plus the 64 computed hashes)
    // The 65th hash is the output hash
    wire [16639:0] intermediate_hashes;
    
    assign intermediate_hashes[255:0] = in_hash;
    
    //Add the input hash to the final intermediate hash. This has to be done one word at a time, to avoid
    //cary over from one word to the next
    assign out_hash[0 * 32 + 31:0 * 32 + 0] = intermediate_hashes[0 * 32 + 16384 + 31:0 * 32 + 16384] + in_hash[0 * 32 + 31:0 * 32 + 0];
    assign out_hash[1 * 32 + 31:1 * 32 + 0] = intermediate_hashes[1 * 32 + 16384 + 31:1 * 32 + 16384] + in_hash[1 * 32 + 31:1 * 32 + 0];
    assign out_hash[2 * 32 + 31:2 * 32 + 0] = intermediate_hashes[2 * 32 + 16384 + 31:2 * 32 + 16384] + in_hash[2 * 32 + 31:2 * 32 + 0];
    assign out_hash[3 * 32 + 31:3 * 32 + 0] = intermediate_hashes[3 * 32 + 16384 + 31:3 * 32 + 16384] + in_hash[3 * 32 + 31:3 * 32 + 0];
    assign out_hash[4 * 32 + 31:4 * 32 + 0] = intermediate_hashes[4 * 32 + 16384 + 31:4 * 32 + 16384] + in_hash[4 * 32 + 31:4 * 32 + 0];
    assign out_hash[5 * 32 + 31:5 * 32 + 0] = intermediate_hashes[5 * 32 + 16384 + 31:5 * 32 + 16384] + in_hash[5 * 32 + 31:5 * 32 + 0];
    assign out_hash[6 * 32 + 31:6 * 32 + 0] = intermediate_hashes[6 * 32 + 16384 + 31:6 * 32 + 16384] + in_hash[6 * 32 + 31:6 * 32 + 0];
    assign out_hash[7 * 32 + 31:7 * 32 + 0] = intermediate_hashes[7 * 32 + 16384 + 31:7 * 32 + 16384] + in_hash[7 * 32 + 31:7 * 32 + 0];
    
    
    
    //assign intermediate_hashes[255:0] = out_hash;
    
    wire [2047:0] k;
    
    assign k = 2048'hc67178f2bef9a3f7a4506ceb90befffa8cc7020884c8781478a5636f748f82ee682e6ff35b9cca4f4ed8aa4a391c0cb334b0bcb52748774c1e376c0819a4c116106aa070f40e3585d6990624d192e819c76c51a3c24b8b70a81a664ba2bfe8a192722c8581c2c92e766a0abb650a735453380d134d2c6dfc2e1b213827b70a851429296706ca6351d5a79147c6e00bf3bf597fc7b00327c8a831c66d983e515276f988da5cb0a9dc4a7484aa2de92c6f240ca1cc0fc19dc6efbe4786e49b69c1c19bf1749bdc06a780deb1fe72be5d74550c7dc3243185be12835b01d807aa98ab1c5ed5923f82a459f111f13956c25be9b5dba5b5c0fbcf71374491428a2f98;
    
    
    
    genvar i;
    generate
        for (i = 1; i < 65; i = i + 1) begin : compression_generate
            compression_round cl0 (
                .w(w[(i-1) * 32 + 31:(i-1) * 32 + 0]),
                .k(k[(i-1) * 32 + 31:(i-1) * 32 + 0]),
                .input_hash(intermediate_hashes[(i-1) * 256 + 255:(i-1) * 256 + 0]),
                .output_hash(intermediate_hashes[(i) * 256 + 255:(i) * 256 + 0]));
        end
    endgenerate

endmodule

//A pure logic (no storage) implementation of the SHA256 algorithm
module logic_sha256(input [255:0] in_hash,
                    input [511:0] block,
                    output [255:0] out_hash);
                    
    wire [2047:0] message;
    
    extend_message es0 (
        .block(block),
        .message(message));
        
    compression c0 (
        .w(message),
        .in_hash(in_hash),
        .out_hash(out_hash));

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

// A module with very few inputs/outputs for the logic_sha256 function
module small_test(input [31:0] message,
            output [31:0] hash);
            
    wire [511:0] m; 
    wire [255:0] in_hash;
    wire [255:0] out_hash;
            
    assign m = { 480'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, message };  
    
    assign in_hash = 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;   
    
    logic_sha256 ls0 (.in_hash(in_hash), .block(m), .out_hash(out_hash));
    
    assign hash = out_hash[31:0];
            
endmodule

// Takes an in_hash (the hash from the first block) and the other bitcoin block attributes and determines whether the block is mined based on the nonce
module bitcoin_test(input [255:0] in_hash,
                    input [31:0] hash_merkle, //Last (or first depending on endianness) word of merkle hash
                    input [31:0] block_time,
                    input [31:0] bits,
                    input [31:0] nonce,
                    output found,
                    output [255:0] bitcoin_hash);
         
    wire [511:0] sha_block;
    wire [511:0] sha_block_2;
    wire [255:0] first_hash;
    wire [255:0] _final_hash;
    wire [255:0] final_hash;
    
    wire [255:0] integer_target;
    
    //Concatenate the hash_merkle, block_time, bits and nonce with the appropriate SHA-256 padding
    assign sha_block = { 384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, bits, block_time, hash_merkle };
    
    //Calculate the first hash
    logic_sha256 ls0 (.in_hash(in_hash), .block(sha_block), .out_hash(first_hash));
    
    //Concatenate the first_hash with the  appropriate SHA-256 padding
    assign sha_block_2 = { 256'h0000010000000000000000000000000000000000000000000000000080000000, first_hash };
    
    //Calculate the second hash
    logic_sha256 ls1 (
        .in_hash(256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667), 
        .block(sha_block_2), 
        .out_hash(_final_hash));

    //Temporary way to correct endianness
    correct_endianness ce0 (_final_hash, final_hash);
        
    // Convert the target from the 32-bit floating format into the 256-bit integer format
    float_target_to_int fti0 (.float_target(bits), .int_target(integer_target));
    
    //If the hash is less than the target, then we have found a suitable nonce
    assign found = final_hash <= integer_target;

    assign bitcoin_hash = final_hash;
                    
endmodule
                    
// A bank of 8 bitcoin_test modules in parallel
module bitcoin_tests_8(input [255:0] in_hash,
                        input [31:0] hash_merkle, //Last (or first depending on endianness) word of merkle hash
                        input [31:0] block_time,
                        input [31:0] bits,
                        input [31:0] nonce,
                        output [7:0] found);

    wire [255:0] nonces;

    assign nonces[0 * 32 + 31:0 * 32 + 0] = nonce + 0;
    assign nonces[1 * 32 + 31:1 * 32 + 0] = nonce + 1;
    assign nonces[2 * 32 + 31:2 * 32 + 0] = nonce + 2;
    assign nonces[3 * 32 + 31:3 * 32 + 0] = nonce + 3;
    assign nonces[4 * 32 + 31:4 * 32 + 0] = nonce + 4;
    assign nonces[5 * 32 + 31:5 * 32 + 0] = nonce + 5;
    assign nonces[6 * 32 + 31:6 * 32 + 0] = nonce + 6;
    assign nonces[7 * 32 + 31:7 * 32 + 0] = nonce + 7;

    genvar i;
    generate 
        for (i = 0; i < 8; i = i + 1)  begin : bus_generate
            bitcoin_test bt0 (.in_hash(in_hash), .hash_merkle(hash_merkle), .block_time(block_time), .bits(bits), .nonce(nonces[i * 32 + 31:i * 32 + 0]), .found(found[i]), .bitcoin_hash());
        end
    endgenerate

endmodule
















