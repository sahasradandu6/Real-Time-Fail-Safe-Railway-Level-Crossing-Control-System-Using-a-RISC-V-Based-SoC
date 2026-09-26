`timescale 1ns/1ps

module aes_axi_slave_tb;

    //============================================================
    // CLOCK / RESET
    //============================================================

    reg clk;
    reg rst_n;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //============================================================
    // AXI WRITE ADDRESS
    //============================================================

    reg  [31:0] s_axi_awaddr;
    reg         s_axi_awvalid;
    wire        s_axi_awready;

    //============================================================
    // AXI WRITE DATA
    //============================================================

    reg  [31:0] s_axi_wdata;
    reg  [3:0]  s_axi_wstrb;
    reg         s_axi_wvalid;
    wire        s_axi_wready;

    //============================================================
    // AXI WRITE RESPONSE
    //============================================================

    wire [1:0] s_axi_bresp;
    wire       s_axi_bvalid;
    reg        s_axi_bready;

    //============================================================
    // AXI READ ADDRESS
    //============================================================

    reg  [31:0] s_axi_araddr;
    reg         s_axi_arvalid;
    wire        s_axi_arready;

    //============================================================
    // AXI READ DATA
    //============================================================

    wire [31:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    reg         s_axi_rready;

    //============================================================
    // DUT
    //============================================================

    aes_axi_slave dut (

        .s_axi_aclk    (clk),
        .s_axi_aresetn (rst_n),

        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awvalid (s_axi_awvalid),
        .s_axi_awready (s_axi_awready),

        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),
        .s_axi_wready  (s_axi_wready),

        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),
        .s_axi_bready  (s_axi_bready),

        .s_axi_araddr  (s_axi_araddr),
        .s_axi_arvalid (s_axi_arvalid),
        .s_axi_arready (s_axi_arready),

        .s_axi_rdata   (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_rready  (s_axi_rready)
    );

    //============================================================
    // TEST DATA
    //============================================================

    reg [31:0] key0;
    reg [31:0] key1;
    reg [31:0] key2;
    reg [31:0] key3;

    reg [31:0] text0;
    reg [31:0] text1;
    reg [31:0] text2;
    reg [31:0] text3;

    reg [31:0] read_value;

    reg [127:0] cipher_result;
    reg [127:0] inverse_result;

    integer errors;
    integer timeout;
    reg done_found;

    //============================================================
    // AXI WRITE
    //============================================================

    task axi_write;

        input [31:0] address;
        input [31:0] data;

        begin

            @(posedge clk);

            s_axi_awaddr  <= address;
            s_axi_awvalid <= 1'b1;

            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'hF;
            s_axi_wvalid  <= 1'b1;

            s_axi_bready  <= 1'b1;

            wait (s_axi_awready && s_axi_wready);

            @(posedge clk);

            s_axi_awvalid <= 1'b0;
            s_axi_wvalid  <= 1'b0;

            wait (s_axi_bvalid);

            @(posedge clk);

            s_axi_bready <= 1'b0;

        end

    endtask

    //============================================================
    // AXI READ
    //============================================================

    task axi_read;

        input  [31:0] address;
        output [31:0] data;

        begin

            @(posedge clk);

            s_axi_araddr  <= address;
            s_axi_arvalid <= 1'b1;
            s_axi_rready  <= 1'b1;

            wait (s_axi_arready);

            @(posedge clk);

            s_axi_arvalid <= 1'b0;

            wait (s_axi_rvalid);

            data = s_axi_rdata;

            @(posedge clk);

            s_axi_rready <= 1'b0;

        end

    endtask

    //============================================================
    // CHECK REGISTER
    //============================================================

    task check_register;

        input [31:0] address;
        input [31:0] expected;
        input [127:0] name;

        reg [31:0] actual;

        begin

            axi_read(address, actual);

            if (actual !== expected) begin

                $display("[FAIL] %0s", name);
                $display("       Expected = 0x%08h", expected);
                $display("       Actual   = 0x%08h", actual);

                errors = errors + 1;

            end
            else begin

                $display("[PASS] %0s = 0x%08h", name, actual);

            end

        end

    endtask

    //============================================================
    // WAIT FOR DONE
    //============================================================

    task wait_for_done;

        begin

            timeout   = 0;
            done_found = 1'b0;

            while ((timeout < 100) && !done_found) begin

                axi_read(32'h00, read_value);

                if (read_value[16] == 1'b1)
                    done_found = 1'b1;

                timeout = timeout + 1;

            end

            if (done_found) begin

                $display("[PASS] DONE detected after %0d polls.",
                         timeout);

            end
            else begin

                $display("[FAIL] DONE timeout.");
                $display("       Final CSR = 0x%08h", read_value);

                errors = errors + 1;

            end

        end

    endtask

    //============================================================
    // WAIT FOR KEY_DONE
    //============================================================

    task wait_for_key_done;

        begin

            timeout    = 0;
            done_found = 1'b0;

            while ((timeout < 100) && !done_found) begin

                axi_read(32'h00, read_value);

                if (read_value[17] == 1'b1)
                    done_found = 1'b1;

                timeout = timeout + 1;

            end

            if (done_found) begin

                $display("[PASS] KEY_DONE detected after %0d polls.",
                         timeout);

            end
            else begin

                $display("[FAIL] KEY_DONE timeout.");
                $display("       Final CSR = 0x%08h", read_value);

                errors = errors + 1;

            end

        end

    endtask

    //============================================================
    // MAIN TEST
    //============================================================

    initial begin

        //========================================================
        // INITIAL VALUES
        //========================================================

        s_axi_awaddr  = 32'h00000000;
        s_axi_awvalid = 1'b0;

        s_axi_wdata   = 32'h00000000;
        s_axi_wstrb   = 4'h0;
        s_axi_wvalid  = 1'b0;

        s_axi_bready  = 1'b0;

        s_axi_araddr  = 32'h00000000;
        s_axi_arvalid = 1'b0;
        s_axi_rready  = 1'b0;

        rst_n = 1'b0;

        errors = 0;

        key0 = 32'h9abcdef1;
        key1 = 32'h12345678;
        key2 = 32'h9abcdef1;
        key3 = 32'h12345678;

        text0 = 32'hbcdef123;
        text1 = 32'h3456789a;
        text2 = 32'habcdef12;
        text3 = 32'h23456789;

        cipher_result  = 128'h0;
        inverse_result = 128'h0;

        //========================================================
        // RESET
        //========================================================

        repeat (5)
            @(posedge clk);

        rst_n = 1'b1;

        repeat (2)
            @(posedge clk);

        //========================================================
        // HEADER
        //========================================================

        $display("");
        $display("======================================================");
        $display("          AES AXI4-LITE REGISTER BANK TEST");
        $display("======================================================");
        $display("Key       = 123456789abcdef1123456789abcdef1");
        $display("Plaintext = 23456789abcdef123456789abcdef123");
        $display("Expected  = 51598687d39d80a2ea17ff303dd9231d");
        $display("");

        //========================================================
        // STEP 1
        //========================================================

        $display("STEP 1: WRITE AES KEY");

        axi_write(32'h04, key0);
        axi_write(32'h08, key1);
        axi_write(32'h0C, key2);
        axi_write(32'h10, key3);

        //========================================================
        // STEP 2
        //========================================================

        $display("");
        $display("STEP 2: VERIFY AES KEY");

        check_register(32'h04, key0, "KEY0");
        check_register(32'h08, key1, "KEY1");
        check_register(32'h0C, key2, "KEY2");
        check_register(32'h10, key3, "KEY3");

        //========================================================
        // STEP 3
        //========================================================

        $display("");
        $display("STEP 3: WRITE PLAINTEXT");

        axi_write(32'h14, text0);
        axi_write(32'h18, text1);
        axi_write(32'h1C, text2);
        axi_write(32'h20, text3);

        //========================================================
        // STEP 4
        //========================================================

        $display("");
        $display("STEP 4: VERIFY PLAINTEXT");

        check_register(32'h14, text0, "TEXT_IN0");
        check_register(32'h18, text1, "TEXT_IN1");
        check_register(32'h1C, text2, "TEXT_IN2");
        check_register(32'h20, text3, "TEXT_IN3");

        //========================================================
        // STEP 5
        //========================================================

        $display("");
        $display("STEP 5: START AES CIPHER");

        axi_write(32'h00, 32'h00000001);

        //========================================================
        // STEP 6
        //========================================================

        $display("");
        $display("STEP 6: WAIT FOR CIPHER DONE");

        wait_for_done;

        //========================================================
        // STEP 7
        //========================================================

        $display("");
        $display("STEP 7: READ CIPHER OUTPUT");

        axi_read(32'h24, cipher_result[31:0]);
        axi_read(32'h28, cipher_result[63:32]);
        axi_read(32'h2C, cipher_result[95:64]);
        axi_read(32'h30, cipher_result[127:96]);

        $display("Cipher Output = %032h", cipher_result);
        $display("Expected      = 51598687d39d80a2ea17ff303dd9231d");

        if (cipher_result !==
            128'h51598687d39d80a2ea17ff303dd9231d) begin

            $display("[FAIL] AES CIPHER OUTPUT");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] AES CIPHER OUTPUT");

        end

        //========================================================
        // STEP 8
        //========================================================

        $display("");
        $display("STEP 8: VERIFY CIPHER DONE");

        axi_read(32'h00, read_value);

        if (read_value[16] !== 1'b1) begin

            $display("[FAIL] CSR[16] DONE = 0");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] CSR[16] DONE = 1");

        end

        //========================================================
        // STEP 9
        //========================================================

        $display("");
        $display("STEP 9: START INVERSE KEY LOAD");

        axi_write(32'h00, 32'h00000002);

        //========================================================
        // STEP 10
        //========================================================

        $display("");
        $display("STEP 10: WAIT FOR KEY_DONE");

        wait_for_key_done;

        //========================================================
        // STEP 11
        //========================================================

        $display("");
        $display("STEP 11: VERIFY KEY_DONE");

        axi_read(32'h00, read_value);

        if (read_value[17] !== 1'b1) begin

            $display("[FAIL] CSR[17] KEY_DONE = 0");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] CSR[17] KEY_DONE = 1");

        end

        //========================================================
        // STEP 12
        //========================================================

        $display("");
        $display("STEP 12: WRITE CIPHERTEXT TO INPUT");

        axi_write(32'h14, cipher_result[31:0]);
        axi_write(32'h18, cipher_result[63:32]);
        axi_write(32'h1C, cipher_result[95:64]);
        axi_write(32'h20, cipher_result[127:96]);

        //========================================================
        // STEP 13
        //========================================================

        $display("");
        $display("STEP 13: START INVERSE CIPHER");

        axi_write(32'h00, 32'h00000001);

        //========================================================
        // STEP 14
        //========================================================

        $display("");
        $display("STEP 14: WAIT FOR INVERSE DONE");

        wait_for_done;

        //========================================================
        // STEP 15
        //========================================================

        $display("");
        $display("STEP 15: READ INVERSE OUTPUT");

        axi_read(32'h24, inverse_result[31:0]);
        axi_read(32'h28, inverse_result[63:32]);
        axi_read(32'h2C, inverse_result[95:64]);
        axi_read(32'h30, inverse_result[127:96]);

        $display("Inverse Output = %032h", inverse_result);
        $display("Expected        = 23456789abcdef123456789abcdef123");

        if (inverse_result !==
            128'h23456789abcdef123456789abcdef123) begin

            $display("[FAIL] AES INVERSE OUTPUT");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] AES INVERSE OUTPUT");

        end

        //========================================================
        // STEP 16
        //========================================================

        $display("");
        $display("STEP 16: FINAL CSR");

        axi_read(32'h00, read_value);

        $display("Final CSR = 0x%08h", read_value);

        if (read_value[16] !== 1'b1) begin

            $display("[FAIL] FINAL DONE");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] FINAL DONE");

        end

        if (read_value[17] !== 1'b1) begin

            $display("[FAIL] FINAL KEY_DONE");
            errors = errors + 1;

        end
        else begin

            $display("[PASS] FINAL KEY_DONE");

        end

        //========================================================
        // FINAL RESULT
        //========================================================

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display("                 ALL TESTS PASSED");
            $display("======================================================");
            $display("AES CIPHER OUTPUT       : PASS");
            $display("AES CIPHER DONE         : PASS");
            $display("INVERSE KEY DONE        : PASS");
            $display("AES INVERSE OUTPUT     : PASS");
            $display("AES INVERSE DONE       : PASS");
            $display("AXI REGISTER ACCESS    : PASS");
            $display("======================================================");

        end
        else begin

            $display("                    TEST FAILED");
            $display("======================================================");
            $display("Number of errors = %0d", errors);
            $display("======================================================");

        end

        #100;

        $finish;

    end
initial begin
    $fsdbDumpfile("dump.fsdb");  // Record the waveform, waveform name testname.fsdb
    $fsdbDumpvars("+all");    // + all parameters, Struct structures in Dump SV
    $fsdbDumpSVA();      // Present the result of Assertion in FSDB
    $fsdbDumpMDA(); 
  end
endmodule
