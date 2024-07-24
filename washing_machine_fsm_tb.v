`timescale	1ns/1ps

module washing_machine_fsm_tb();

////////////////////// DUT Signals & Parameters //////////////////////


reg				RST, CLK;
reg				ON_SUMMER, ON_WINTER; 
reg				TIMER_DONE; 		
reg				DOOR_SENSOR, WATER_SENSOR_M, WATER_SENSOR_H;	

wire	[1:0]	TIMER_SEL;										
wire			TIMER_EN, WASHER_EN, WATER_EN, SPIN_EN, DRAIN_EN;
wire			FILLING, ACTIVE, DRAIN, SPIN, IDLE, DONE;      

parameter	CLK_Period = 20,
			idle_op    = 'b111,
            fill_med   = 'b110,
			fill_high  = 'b101,
            activate   = 'b100,
            drain      = 'b000,
            spin_op    = 'b001,
            end_op     = 'b011;

////////////////////// Initial Block //////////////////////

initial
begin
	
	//// Initialization
	initialize();
	
	//// Reset
	reset();
	
	//////// Start Testing ////////
	
	//// Testing Idle
	$display("############ Test Initial Idle State ############");
	if(IDLE) $display("Functional");
	else	  $display("Error");
	#(CLK_Period);
	
	
	//// Testing Reset
	$display("############# Test Reset ################");
	ON_SUMMER   = 'b1;		//Filling_Medium State
	DOOR_SENSOR = 'b1;
	#(CLK_Period)
	reset();
		if(IDLE && !FILLING) $display("Functional");
		else	  $display("Error");
	ON_SUMMER   = 'b0;
	DOOR_SENSOR = 'b0;
	#(CLK_Period)
	
	
	///////////////////////// Testing Filling Medium Operation ///////////////////////
	$display("################## Test Filling Medium State ######################");
	ON_SUMMER   = 'b1;		//Filling_Medium State
	DOOR_SENSOR = 'b1;
	#(CLK_Period)
	ON_SUMMER   = 'b0;
	DOOR_SENSOR = 'b0;
	@(negedge CLK)
	if(FILLING) $display("Functional");
	else	    $display("Error");
	
	//// Testing Activate "Medium"
	$display("############# Test Activate State (On Medium) ################");
	WATER_SENSOR_M = 'b1;
	#(CLK_Period)
	@(negedge CLK)
	if(ACTIVE && (TIMER_SEL == 'b01) && TIMER_EN && WASHER_EN) $display("Functional");
	else	  $display("Error");
	
	//// Testing Drain
	$display("######### Test Drain State ###########");
	TIMER_DONE = 'b1;
	#(CLK_Period)
	TIMER_DONE = 'b0;
	@(negedge CLK)
	if(DRAIN && DRAIN_EN) $display("Functional");
	else	    $display("Error");
	
	
	//// Testing Spin
	$display("######### Test Spin State ###########");
	WATER_SENSOR_M = 'b0;
	#(CLK_Period)
	@(negedge CLK)
	if(SPIN && SPIN_EN && (TIMER_SEL == 'b11)) $display("Functional");
	else	    $display("Error");
	
	//// Testing End
	$display("######### Test End State ###########");
	TIMER_DONE = 'b1;
	#(CLK_Period)
	TIMER_DONE = 'b0;
	@(negedge CLK)
	if(DONE) $display("Functional");
	else	    $display("Error");
	
	//// Testing Idle
	$display("############ Test Back to Idle State ############");
	DOOR_SENSOR = 'b0;
	#(CLK_Period)
	if(IDLE) $display("Functional");
	else	  $display("Error");
	#(CLK_Period);
	
	
	///////////////////////// Testing Filling High Operation ///////////////////////
	$display("################## Test Filling High State ######################");
	ON_WINTER   = 'b1;
	DOOR_SENSOR = 'b1;
	#(CLK_Period)
	ON_WINTER   = 'b0;
	DOOR_SENSOR = 'b0;
	@(negedge CLK)
	if(FILLING) $display("Functional");
	else	    $display("Error");
	ON_WINTER = 'b0;
	
	//// Testing Activate "Medium"
	$display("############# Test Activate State (On High) ################");
	WATER_SENSOR_M = 'b1;
	#(CLK_Period)
	WATER_SENSOR_H = 'b1;
	#(CLK_Period)
	@(negedge CLK)
	if(ACTIVE && (TIMER_SEL == 'b10) && TIMER_EN && WASHER_EN) $display("Functional");
	else	  $display("Error");
	
	//// Testing Drain
	$display("######### Test Drain State ###########");
	TIMER_DONE = 'b1;
	#(CLK_Period)
	TIMER_DONE = 'b0;
	@(negedge CLK)
	if(DRAIN && DRAIN_EN) $display("Functional");
	else	    $display("Error");
	
	
	//// Testing Spin
	$display("######### Test Spin State ###########");
	WATER_SENSOR_H = 'b0;
	#(CLK_Period)
	WATER_SENSOR_M = 'b0;
	#(CLK_Period)
	@(negedge CLK)
	if(SPIN && SPIN_EN && (TIMER_SEL == 'b11)) $display("Functional");
	else	    $display("Error");
	
	//// Testing End
	$display("######### Test End State ###########");
	TIMER_DONE = 'b1;
	#(CLK_Period)
	TIMER_DONE = 'b0;
	@(negedge CLK)
	if(DONE) $display("Functional");
	else	    $display("Error");
	
	//// Testing Idle
	$display("############ Test Back to Idle State ############");
	DOOR_SENSOR = 'b0;
	#(CLK_Period)
	if(IDLE) $display("Functional");
	else	  $display("Error");
	#(CLK_Period);
	
	
	
	
	
	#(5*CLK_Period)
	$stop;
end

////////////////////// Tasks //////////////////////

//// Initialize Task

task initialize;
begin
	RST				= 'b1;
	CLK				= 'b1;
	ON_SUMMER		= 'b0;
	ON_WINTER	    = 'b0;
	TIMER_DONE      = 'b0;
	DOOR_SENSOR     = 'b0;
	WATER_SENSOR_M  = 'b0;
	WATER_SENSOR_H  = 'b0;
end
endtask

//// Reset Task

task reset;
 begin
	RST  = 'b1;
	#(CLK_Period)
	RST  = 'b0;
	#(CLK_Period)
	RST  = 'b1;
 end
endtask

////////////////////// Clock Generation //////////////////////

always #(0.5*CLK_Period) CLK = !CLK;

////////////////////// DUT Instantiation //////////////////////

washing_machine_fsm DUT (
.RST(RST),				
.CLK(CLK),		
.ON_SUMMER(ON_SUMMER),		
.ON_WINTER(ON_WINTER),	    
.TIMER_DONE(TIMER_DONE),
.DOOR_SENSOR(DOOR_SENSOR),
.WATER_SENSOR_M(WATER_SENSOR_M),
.WATER_SENSOR_H(WATER_SENSOR_H),
.TIMER_SEL(TIMER_SEL),				
.TIMER_EN(TIMER_EN),
.WASHER_EN(WASHER_EN),
.WATER_EN(WATER_EN),
.SPIN_EN(SPIN_EN),
.DRAIN_EN(DRAIN_EN),
.FILLING(FILLING),
.ACTIVE(ACTIVE),
.DRAIN(DRAIN),
.SPIN(SPIN),
.IDLE(IDLE),
.DONE(DONE)
);


endmodule