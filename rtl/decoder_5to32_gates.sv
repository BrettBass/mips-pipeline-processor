module decoder_5to32_gates (
    output logic [31:0] out,
    input  logic [4:0]  adr // Adr=Address of register
);
    logic nota, notb, notc, notd, note;

    not #(50) inv4(nota, adr[4]);
    not #(50) inv3(notb, adr[3]);
    not #(50) inv2(notc, adr[2]);
    not #(50) inv1(notd, adr[1]);
    not #(50) inv0(note, adr[0]);

    mux_andmore a0  (out[0],  nota, notb, notc, notd, note);  // 00000
    mux_andmore a1  (out[1],  nota, notb, notc, notd, adr[0]); // 00001
    mux_andmore a2  (out[2],  nota, notb, notc, adr[1], note); // 00010
    mux_andmore a3  (out[3],  nota, notb, notc, adr[1], adr[0]);
    mux_andmore a4  (out[4],  nota, notb, adr[2], notd, note);
    mux_andmore a5  (out[5],  nota, notb, adr[2], notd, adr[0]);
    mux_andmore a6  (out[6],  nota, notb, adr[2], adr[1], note);
    mux_andmore a7  (out[7],  nota, notb, adr[2], adr[1], adr[0]);
    mux_andmore a8  (out[8],  nota, adr[3], notc, notd, note);
    mux_andmore a9  (out[9],  nota, adr[3], notc, notd, adr[0]);
    mux_andmore a10 (out[10], nota, adr[3], notc, adr[1], note);
    mux_andmore a11 (out[11], nota, adr[3], notc, adr[1], adr[0]);
    mux_andmore a12 (out[12], nota, adr[3], adr[2], notd, note);
    mux_andmore a13 (out[13], nota, adr[3], adr[2], notd, adr[0]);
    mux_andmore a14 (out[14], nota, adr[3], adr[2], adr[1], note);
    mux_andmore a15 (out[15], nota, adr[3], adr[2], adr[1], adr[0]);
    mux_andmore a16 (out[16], adr[4], notb, notc, notd, note);
    mux_andmore a17 (out[17], adr[4], notb, notc, notd, adr[0]);
    mux_andmore a18 (out[18], adr[4], notb, notc, adr[1], note);
    mux_andmore a19 (out[19], adr[4], notb, notc, adr[1], adr[0]);
    mux_andmore a20 (out[20], adr[4], notb, adr[2], notd, note);
    mux_andmore a21 (out[21], adr[4], notb, adr[2], notd, adr[0]);
    mux_andmore a22 (out[22], adr[4], notb, adr[2], adr[1], note);
    mux_andmore a23 (out[23], adr[4], notb, adr[2], adr[1], adr[0]);
    mux_andmore a24 (out[24], adr[4], adr[3], notc, notd, note);
    mux_andmore a25 (out[25], adr[4], adr[3], notc, notd, adr[0]);
    mux_andmore a26 (out[26], adr[4], adr[3], notc, adr[1], note);
    mux_andmore a27 (out[27], adr[4], adr[3], notc, adr[1], adr[0]);
    mux_andmore a28 (out[28], adr[4], adr[3], adr[2], notd, note);
    mux_andmore a29 (out[29], adr[4], adr[3], adr[2], notd, adr[0]);
    mux_andmore a30 (out[30], adr[4], adr[3], adr[2], adr[1], note);
    mux_andmore a31 (out[31], adr[4], adr[3], adr[2], adr[1], adr[0]); // 11111
endmodule

/*
module decoder_5to32_gates_sv (
    output logic [31:0] out,
    input  logic [4:0]  adr // Adr=Address of register
);

    logic [4:0] not_adr;

    not #(50) not_gate [4:0] (not_adr, adr);

    generate
        for (integer i = 0; i < 32; i++) begin : decode_row
            logic and_term = 1'b1;
            for (integer j = 0; j < 5; j++) begin
                if ((i >> j) & 1'b1) begin
                    and_term = and_term & adr[j];
                end else begin
                    and_term = and_term & not_adr[j];
                end
            end
            assign #(50) out[i] = and_term;
        end
    endgenerate

endmodule
*/
