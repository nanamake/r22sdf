//----------------------------------------------------------------------
//	Test Stimuli
//----------------------------------------------------------------------
initial begin : STIM
	wait (reset == 1);
	wait (reset == 0);
	repeat(10) @(posedge clock);

	fork
		begin
			LoadInputData("input4.txt");
			GenerateInputWave;
			@(posedge clock);
			LoadInputData("input5.txt");
			GenerateInputWave;
		end
		begin
			wait (do_en == 1);
			repeat(64) @(posedge clock);
			SaveOutputData("output4.txt");
			@(negedge clock);
			wait (do_en == 1);
			repeat(64) @(posedge clock);
			SaveOutputData("output5.txt");
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
