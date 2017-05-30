//----------------------------------------------------------------------
//	Test Stimuli
//----------------------------------------------------------------------
initial begin : STIM
	wait (reset == 1);
	wait (reset == 0);
	repeat(10) @(posedge clock);

	fork
		begin
			LoadInputData("input1.txt");
			GenerateInputWave;
		//	repeat(10) @(posedge clock);
			LoadInputData("input2.txt");
			GenerateInputWave;
		end
		begin
			wait (odata_en == 1);
		//	wait (odata_en == 0);
			repeat(N) @(posedge clock);
			SaveOutputData("output1.txt");
		//	wait (odata_en == 1);
		//	wait (odata_en == 0);
			repeat(N) @(posedge clock);
			SaveOutputData("output2.txt");
		end
	join

	repeat(10) @(posedge clock);
	$finish;
end
initial begin : TIMEOUT
	repeat(1000) #20;	//  1000 Clock Cycle Time
	$display("[FAILED] Simulation timed out.");
	$finish;
end
