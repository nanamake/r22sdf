//----------------------------------------------------------------------
//	Test Stimuli
//----------------------------------------------------------------------
initial begin : STIM
	wait (reset == 1);
	wait (reset == 0);
	repeat(10) @(posedge clock);

//	LoadInputData("input1.txt");
	LoadInputData("input2.txt");
	GenerateInputWave;
	wait (odata_en == 1);
	wait (odata_en == 0);
//	SaveOutputData("output1.txt");
	SaveOutputData("output2.txt");

	repeat(10) @(posedge clock);
	$finish;
end
initial begin : TIMEOUT
	repeat(1000) #20;	//  1000 Clock Cycle Time
	$display("[FAILED] Simulation timed out.");
	$finish;
end
