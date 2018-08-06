//----------------------------------------------------------------------
//	TB: FftTop Testbench
//----------------------------------------------------------------------
`timescale	1ns/1ns
module TB #(
	parameter	N = 128
);

localparam		NN = log2(N);	//	Count Bit Width of FFT Point

//	log2 constant function
function integer log2;
	input integer x;
	integer value;
	begin
		value = x-1;
		for (log2=0; value>0; log2=log2+1)
			value = value>>1;
	end
endfunction

//	Internal Regs and Nets
reg			clock;
reg			reset;
reg			idata_en;
reg	[15:0]	idata_r;
reg	[15:0]	idata_i;
wire		odata_en;
wire[15:0]	odata_r;
wire[15:0]	odata_i;

reg	[15:0]	imem[0:2*N-1];
reg	[15:0]	omem[0:2*N-1];

//----------------------------------------------------------------------
//	Clock and Reset
//----------------------------------------------------------------------
initial begin
	clock = 0; #10;
	forever begin
		clock = 1; #10;
		clock = 0; #10;
	end
end

initial begin
	reset = 0; #20;
	reset = 1; #100;
	reset = 0;
end

//----------------------------------------------------------------------
//	Functional Blocks
//----------------------------------------------------------------------

//	Input Control Initialize
initial begin
	wait (reset == 1);
	idata_en = 0;
end

//	Output Data Capture
initial begin : OCAP
	integer		n;
	forever begin
		n = 0;
		while (odata_en !== 1) @(negedge clock);
		while ((odata_en == 1) && (n < N)) begin
			omem[2*n  ] = odata_r;
			omem[2*n+1] = odata_i;
			n = n + 1;
			@(negedge clock);
		end
	end
end

//----------------------------------------------------------------------
//	Tasks
//----------------------------------------------------------------------
task LoadInputData;
	input[80*8:1]	filename;
begin
	$readmemh(filename, imem);
end
endtask

task GenerateInputWave;
	integer	n;
begin
	idata_en <= 1;
	for (n = 0; n < N; n = n + 1) begin
		idata_r <= imem[2*n];
		idata_i <= imem[2*n+1];
		@(posedge clock);
	end
	idata_en <= 0;
	idata_r <= 'bx;
	idata_i <= 'bx;
end
endtask

task SaveOutputData;
	input[80*8:1]	filename;
	integer			fp, n, m, i;
begin
	fp = $fopen(filename);
	m = 0;
	for (n = 0; n < N; n = n + 1) begin
		for (i = 0; i < NN; i = i + 1) m[NN-1-i] = n[i];
		$fdisplay(fp, "%h  %h  // %d", omem[2*m], omem[2*m+1], n[NN-1:0]);
	end
	$fclose(fp);
end
endtask

//----------------------------------------------------------------------
//	Module Instances
//----------------------------------------------------------------------
FFT FFT (
	.clock		(clock		),	//	i
	.reset		(reset		),	//	i
	.idata_en	(idata_en	),	//	i
	.idata_r	(idata_r	),	//	i
	.idata_i	(idata_i	),	//	i
	.odata_en	(odata_en	),	//	o
	.odata_r	(odata_r	),	//	o
	.odata_i	(odata_i	)	//	o
);

//----------------------------------------------------------------------
//	Include Stimuli
//----------------------------------------------------------------------
`include "stim.v"

endmodule
