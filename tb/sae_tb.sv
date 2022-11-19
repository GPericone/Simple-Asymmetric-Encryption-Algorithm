module sae_tb_checks;

    reg clk = 1'b0;
    always #5 clk = !clk;
  
    reg rst_n = 1'b0;
    initial #12.8 rst_n = 1'b1;

    reg [1:0] mode_w;
    reg [7:0] data_input_w;
    reg [7:0] key_input_w;
    reg inputs_valid_w;
    wire output_ready_w;
    wire [7:0] data_output_w;
    wire err_invalid_ptxt_char_w;
    wire err_invalid_seckey_w;
    wire err_invalid_ctxt_char_w;

    sae sae_walt(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode_w)
    ,.data_input                (data_input_w)
    ,.key_input                 (key_input_w)
    ,.inputs_valid              (inputs_valid_w)
    ,.data_output               (data_output_w)
    ,.output_ready              (output_ready_w)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char_w)
    ,.err_invalid_seckey        (err_invalid_seckey_w)
    ,.err_invalid_ctxt_char     (err_invalid_ctxt_char_w)
    );

    reg [1:0] mode_j;
    reg [7:0] data_input_j;
    reg [7:0] key_input_j;
    reg inputs_valid_j;
    wire output_ready_j;
    wire [7:0] data_output_j;
    wire err_invalid_ptxt_char_j;
    wire err_invalid_seckey_j;
    wire err_invalid_ctxt_char_j;

    sae sae_jesse(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode_j)
    ,.data_input                (data_input_j)
    ,.key_input                 (key_input_j)
    ,.inputs_valid              (inputs_valid_j)
    ,.data_output               (data_output_j)
    ,.output_ready              (output_ready_j)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char_j)
    ,.err_invalid_seckey        (err_invalid_seckey_j)
    ,.err_invalid_ctxt_char     (err_invalid_ctxt_char_j)
    );

    int FILE;
    reg [7:0] PTXT_W [$];
    reg [7:0] CTXT_W [$];
    string char;

	initial begin
        @(posedge rst_n);
    
        // Walt generates the public key and sends to Jesse
        @(posedge clk);
        FILE = $fopen("tv/privatekey_w.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_w);
        $display("Private key loaded");
        $fclose(FILE);
        mode_w = 2'b01;
        data_input_w = 8'd0;
        inputs_valid_w = 1'b1;
        @(posedge clk);
        inputs_valid_w = 1'b0;
        @(posedge clk);
        #3 if (output_ready_w == 1'b1) begin
            FILE = $fopen("tv/publickey_j.txt", "wb");
            $fwrite(FILE, "%b", data_output_w);
            $fclose(FILE);
        end
        else
            $write("Output non ready yet");

        // Jesse generates the public key and sends to Walt

        FILE = $fopen("tv/privatekey_j.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_j);
        $display("Private key loaded");
        $fclose(FILE);
        mode_j = 2'b01;
        data_input_j = 8'd0;
        inputs_valid_j = 1'b1;
        @(posedge clk);
        inputs_valid_j = 1'b0;
        @(posedge clk);
        #3 if (output_ready_j == 1'b1) begin
            FILE = $fopen("tv/publickey_w.txt", "wb");
            $fwrite(FILE, "%b", data_output_j);
            $fclose(FILE);
        end
        else
            $write("Output non ready yet");

        // Walt encrypt the plaintext with the Jesse's public key

        FILE = $fopen("tv/publickey_w.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_w);
        $display("Public key loaded");
        $fclose(FILE);
        FILE = $fopen("tv/plaintext_w.txt", "r");
        while($fscanf(FILE, "%c", char) == 1) begin
            data_input_w = int'(char);
            mode_w = 2'b10;
            inputs_valid_w = 1'b1;
            @(posedge clk);
            inputs_valid_w = 1'b0;
            @(posedge clk);
        // CONTROLLO CHE NON CI SIANO ERRORI
            #3 if (output_ready_w == 1'b1)
                CTXT_W.push_back(data_output_w);
            else
               $write("Output non ready yet"); 
        end
        $fclose(FILE);

        FILE = $fopen("tv/ciphertext_j.txt", "w");
        foreach(CTXT_W[i])
            $fwrite(FILE, "%c", CTXT_W[i]);
        $fclose(FILE);

    end
endmodule
