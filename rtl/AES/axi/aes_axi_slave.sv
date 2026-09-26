`timescale 1ns/1ps

module aes_axi_slave #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 32
)(
    input  wire                               s_axi_aclk,
    input  wire                               s_axi_aresetn,

    input  wire [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input  wire                               s_axi_awvalid,
    output wire                               s_axi_awready,

    input  wire [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]  s_axi_wstrb,
    input  wire                               s_axi_wvalid,
    output wire                               s_axi_wready,

    output reg  [1:0]                         s_axi_bresp,
    output reg                                s_axi_bvalid,
    input  wire                               s_axi_bready,

    input  wire [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr,
    input  wire                               s_axi_arvalid,
    output wire                               s_axi_arready,

    output reg  [C_S_AXI_DATA_WIDTH-1:0]      s_axi_rdata,
    output reg  [1:0]                         s_axi_rresp,
    output reg                                s_axi_rvalid,
    input  wire                               s_axi_rready
);

    //------------------------------------------------------------
    // AXI constants
    //------------------------------------------------------------
    localparam [1:0] AXI_OKAY = 2'b00;

    //------------------------------------------------------------
    // AXI write channel storage
    //------------------------------------------------------------
    reg [C_S_AXI_ADDR_WIDTH-1:0] awaddr_reg;
    reg                           aw_pending;

    reg [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;
    reg [(C_S_AXI_DATA_WIDTH/8)-1:0] wstrb_reg;
    reg                           w_pending;

    wire aw_fire;
    wire w_fire;

    assign s_axi_awready = !aw_pending && !s_axi_bvalid;
    assign s_axi_wready  = !w_pending  && !s_axi_bvalid;

    assign aw_fire = s_axi_awvalid && s_axi_awready;
    assign w_fire  = s_axi_wvalid  && s_axi_wready;

    //------------------------------------------------------------
    // AES software-visible registers
    //------------------------------------------------------------
    reg [31:0] key0_reg;
    reg [31:0] key1_reg;
    reg [31:0] key2_reg;
    reg [31:0] key3_reg;

    reg [31:0] text_in0_reg;
    reg [31:0] text_in1_reg;
    reg [31:0] text_in2_reg;
    reg [31:0] text_in3_reg;

    reg [31:0] text_out0_reg;
    reg [31:0] text_out1_reg;
    reg [31:0] text_out2_reg;
    reg [31:0] text_out3_reg;

    //------------------------------------------------------------
    // AES control/status
    //------------------------------------------------------------
    reg inverse_mode;

    reg done_status;
    reg key_done_status;

    //------------------------------------------------------------
    // One-cycle AES control pulses
    //------------------------------------------------------------
    reg cipher_ld;
    reg inverse_ld;
    reg inverse_kld;

    //------------------------------------------------------------
    // Inverse key-load timing
    //
    // aes_inv_cipher_top internally loads:
    //   kb[10] ... kb[0]
    //
    // kcnt starts at 10 and decrements while kb_ld is active.
    // KEY_DONE is therefore generated after the complete
    // 11-word inverse key schedule has been loaded.
    //------------------------------------------------------------
    reg [3:0] key_load_count;

    //------------------------------------------------------------
    // AES core connections
    //------------------------------------------------------------
    wire [127:0] aes_key;
    wire [127:0] aes_text_in;

    wire [127:0] cipher_text_out;
    wire [127:0] inverse_text_out;

    wire cipher_done;
    wire inverse_done;

    assign aes_key = {
        key3_reg,
        key2_reg,
        key1_reg,
        key0_reg
    };

    assign aes_text_in = {
        text_in3_reg,
        text_in2_reg,
        text_in1_reg,
        text_in0_reg
    };

    //------------------------------------------------------------
    // AES encryption core
    //------------------------------------------------------------
    aes_cipher_top u_aes_cipher (
        .clk      (s_axi_aclk),
        .rst      (s_axi_aresetn),
        .ld       (cipher_ld),
        .done     (cipher_done),
        .key      (aes_key),
        .text_in  (aes_text_in),
        .text_out (cipher_text_out)
    );

    //------------------------------------------------------------
    // AES inverse/decryption core
    //------------------------------------------------------------
    aes_inv_cipher_top u_aes_inverse (
        .clk      (s_axi_aclk),
        .rst      (s_axi_aresetn),
        .kld      (inverse_kld),
        .ld       (inverse_ld),
        .done     (inverse_done),
        .key      (aes_key),
        .text_in  (aes_text_in),
        .text_out (inverse_text_out)
    );

    //------------------------------------------------------------
    // Write transaction complete condition
    //------------------------------------------------------------
    wire write_complete;

    assign write_complete =
        !s_axi_bvalid &&
        (aw_pending || aw_fire) &&
        (w_pending  || w_fire);

    //------------------------------------------------------------
    // Effective write address/data/strobes
    //------------------------------------------------------------
    wire [C_S_AXI_ADDR_WIDTH-1:0] effective_awaddr =
        aw_pending ? awaddr_reg : s_axi_awaddr;

    wire [31:0] effective_wdata =
        w_pending ? wdata_reg : s_axi_wdata;

    wire [3:0] effective_wstrb =
        w_pending ? wstrb_reg : s_axi_wstrb;

    //------------------------------------------------------------
    // AXI read
    //------------------------------------------------------------
    assign s_axi_arready = !s_axi_rvalid;

    //------------------------------------------------------------
    // Read data mux
    //------------------------------------------------------------
    reg [31:0] read_data;

    always @(*) begin
        read_data = 32'h00000000;

        case (s_axi_araddr[7:0])

            8'h00: begin
                read_data = 32'h00000000;

                // LOAD and KEY_LOAD are commands.
                // They are self-clearing and therefore read as 0.

                read_data[16] = done_status;
                read_data[17] = key_done_status;
            end

            8'h04:
                read_data = key0_reg;

            8'h08:
                read_data = key1_reg;

            8'h0C:
                read_data = key2_reg;

            8'h10:
                read_data = key3_reg;

            8'h14:
                read_data = text_in0_reg;

            8'h18:
                read_data = text_in1_reg;

            8'h1C:
                read_data = text_in2_reg;

            8'h20:
                read_data = text_in3_reg;

            8'h24:
                read_data = text_out0_reg;

            8'h28:
                read_data = text_out1_reg;

            8'h2C:
                read_data = text_out2_reg;

            8'h30:
                read_data = text_out3_reg;

            default:
                read_data = 32'h00000000;

        endcase
    end

    //------------------------------------------------------------
    // Main sequential logic
    //------------------------------------------------------------
    always @(posedge s_axi_aclk) begin

        //--------------------------------------------------------
        // Reset
        //--------------------------------------------------------
        if (!s_axi_aresetn) begin

            awaddr_reg      <= 32'h00000000;
            aw_pending      <= 1'b0;

            wdata_reg       <= 32'h00000000;
            wstrb_reg       <= 4'h0;
            w_pending       <= 1'b0;

            s_axi_bvalid    <= 1'b0;
            s_axi_bresp     <= AXI_OKAY;

            s_axi_rvalid    <= 1'b0;
            s_axi_rresp     <= AXI_OKAY;
            s_axi_rdata     <= 32'h00000000;

            key0_reg        <= 32'h00000000;
            key1_reg        <= 32'h00000000;
            key2_reg        <= 32'h00000000;
            key3_reg        <= 32'h00000000;

            text_in0_reg    <= 32'h00000000;
            text_in1_reg    <= 32'h00000000;
            text_in2_reg    <= 32'h00000000;
            text_in3_reg    <= 32'h00000000;

            text_out0_reg   <= 32'h00000000;
            text_out1_reg   <= 32'h00000000;
            text_out2_reg   <= 32'h00000000;
            text_out3_reg   <= 32'h00000000;

            inverse_mode    <= 1'b0;

            done_status     <= 1'b0;
            key_done_status <= 1'b0;

            cipher_ld       <= 1'b0;
            inverse_ld      <= 1'b0;
            inverse_kld     <= 1'b0;

            key_load_count  <= 4'd0;
        end

        //--------------------------------------------------------
        // Normal operation
        //--------------------------------------------------------
        else begin

            //----------------------------------------------------
            // Default: AES control signals are one-cycle pulses
            //----------------------------------------------------
            cipher_ld   <= 1'b0;
            inverse_ld  <= 1'b0;
            inverse_kld <= 1'b0;

            //----------------------------------------------------
            // Capture AW channel
            //----------------------------------------------------
            if (aw_fire) begin
                awaddr_reg <= s_axi_awaddr;
                aw_pending <= 1'b1;
            end

            //----------------------------------------------------
            // Capture W channel
            //----------------------------------------------------
            if (w_fire) begin
                wdata_reg  <= s_axi_wdata;
                wstrb_reg  <= s_axi_wstrb;
                w_pending  <= 1'b1;
            end

            //----------------------------------------------------
            // Complete AXI write
            //----------------------------------------------------
            if (write_complete) begin

                //------------------------------------------------
                // KEY0
                //------------------------------------------------
                if (effective_awaddr[7:0] == 8'h04) begin
                    if (effective_wstrb[0])
                        key0_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        key0_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        key0_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        key0_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // KEY1
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h08) begin
                    if (effective_wstrb[0])
                        key1_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        key1_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        key1_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        key1_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // KEY2
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h0C) begin
                    if (effective_wstrb[0])
                        key2_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        key2_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        key2_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        key2_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // KEY3
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h10) begin
                    if (effective_wstrb[0])
                        key3_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        key3_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        key3_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        key3_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // TEXT_IN0
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h14) begin
                    if (effective_wstrb[0])
                        text_in0_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        text_in0_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        text_in0_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        text_in0_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // TEXT_IN1
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h18) begin
                    if (effective_wstrb[0])
                        text_in1_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        text_in1_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        text_in1_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        text_in1_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // TEXT_IN2
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h1C) begin
                    if (effective_wstrb[0])
                        text_in2_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        text_in2_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        text_in2_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        text_in2_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // TEXT_IN3
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h20) begin
                    if (effective_wstrb[0])
                        text_in3_reg[7:0]   <= effective_wdata[7:0];

                    if (effective_wstrb[1])
                        text_in3_reg[15:8]  <= effective_wdata[15:8];

                    if (effective_wstrb[2])
                        text_in3_reg[23:16] <= effective_wdata[23:16];

                    if (effective_wstrb[3])
                        text_in3_reg[31:24] <= effective_wdata[31:24];
                end

                //------------------------------------------------
                // CSR
                //------------------------------------------------
                else if (effective_awaddr[7:0] == 8'h00) begin

                    //------------------------------------------------
                    // KEY_LOAD = CSR[1]
                    //------------------------------------------------
                    if (effective_wstrb[0] &&
                        effective_wdata[1]) begin

                        // Select inverse mode
                        inverse_mode <= 1'b1;

                        // Clear previous key completion
                        key_done_status <= 1'b0;

                        // Start one-cycle inverse key load
                        inverse_kld <= 1'b1;

                        // 11 key words: kb[10] ... kb[0]
                        key_load_count <= 4'd11;
                    end

                    //------------------------------------------------
                    // LOAD = CSR[0]
                    //------------------------------------------------
                    if (effective_wstrb[0] &&
                        effective_wdata[0]) begin

                        // New operation clears previous DONE
                        done_status <= 1'b0;

                        if (inverse_mode) begin
                            inverse_ld <= 1'b1;
                        end
                        else begin
                            cipher_ld <= 1'b1;
                        end
                    end
                end

                //------------------------------------------------
                // Finish write transaction
                //------------------------------------------------
                aw_pending   <= 1'b0;
                w_pending    <= 1'b0;

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= AXI_OKAY;
            end

            //----------------------------------------------------
            // AXI write response handshake
            //----------------------------------------------------
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            //----------------------------------------------------
            // Inverse KEY_DONE timer
            //----------------------------------------------------
            if (key_load_count != 4'd0) begin

                if (key_load_count == 4'd1) begin
                    key_load_count  <= 4'd0;
                    key_done_status <= 1'b1;
                end
                else begin
                    key_load_count <= key_load_count - 4'd1;
                end
            end

            //----------------------------------------------------
            // Encryption completed
            //----------------------------------------------------
            if (cipher_done) begin
                done_status   <= 1'b1;

                text_out0_reg <= cipher_text_out[31:0];
                text_out1_reg <= cipher_text_out[63:32];
                text_out2_reg <= cipher_text_out[95:64];
                text_out3_reg <= cipher_text_out[127:96];
            end

            //----------------------------------------------------
            // Inverse encryption completed
            //----------------------------------------------------
            if (inverse_done) begin
                done_status   <= 1'b1;

                text_out0_reg <= inverse_text_out[31:0];
                text_out1_reg <= inverse_text_out[63:32];
                text_out2_reg <= inverse_text_out[95:64];
                text_out3_reg <= inverse_text_out[127:96];
            end

            //----------------------------------------------------
            // AXI read response
            //----------------------------------------------------
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rdata  <= read_data;
                s_axi_rresp  <= AXI_OKAY;
                s_axi_rvalid <= 1'b1;
            end

            //----------------------------------------------------
            // AXI read response handshake
            //----------------------------------------------------
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end

        end
    end

endmodule
