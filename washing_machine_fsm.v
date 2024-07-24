module washing_machine_fsm (
    input   wire                RST, CLK,
    input   wire                ON_SUMMER, ON_WINTER, 
    input   wire                TIMER_DONE, 
    input   wire                DOOR_SENSOR, WATER_SENSOR_M, WATER_SENSOR_H,		//Door sensor high when closed				
    output  reg     [1 : 0]     TIMER_SEL,											//Decides Timing
    output  reg                 TIMER_EN, WASHER_EN, WATER_EN, SPIN_EN, DRAIN_EN,	//Control Enable Signals
    output  reg                 FILLING, ACTIVE, DRAIN, SPIN, IDLE, DONE            //Flags
);

// States for the FSM			PS. Gray Encoded ;)
parameter   idle_op   = 'b111,
            fill_med  = 'b110,
			fill_high = 'b101,
            activate  = 'b100,
            drain     = 'b000,
            spin_op   = 'b001,
            end_op    = 'b011; 

// State Register
reg [2:0] current_state, next_state;


always@(posedge CLK, negedge RST)		//Active low asynchronous reset
 begin
    if(!RST)
        current_state <= idle_op;
    else
        current_state <= next_state;
 end


// Next State Logic
always@(*) 
 begin
    
	//Flags
	FILLING	= 'b0;
	ACTIVE	= 'b0; 
	DRAIN	= 'b0;
	SPIN	= 'b0; 
	IDLE	= 'b0;  
	DONE	= 'b0;
	
	//Control Enable Signals
	TIMER_EN   = 'b0;
	WASHER_EN  = 'b0;
	WATER_EN   = 'b0;
	SPIN_EN    = 'b0;
	DRAIN_EN   = 'b0;
	
	case (current_state)
        idle_op:    begin
                    
					IDLE = 'b1;
					if(ON_SUMMER && !ON_WINTER && DOOR_SENSOR) 
						next_state = fill_med;
					
					else if(ON_WINTER && !ON_SUMMER && DOOR_SENSOR)
						next_state = fill_high;					
					
					else next_state = idle_op;
					
                    end
        
		
		fill_med:   begin
					
					FILLING  = 'b1;
					WATER_EN = 'b1;
					
					if(WATER_SENSOR_M)		//Water level medium
						next_state = activate;
						
					else next_state = fill_med;
					
                    end

		fill_high:  begin
					
					FILLING  = 'b1;
					WATER_EN = 'b1;
					
					if(WATER_SENSOR_H)		//Water level filled
						next_state = activate;
						
					else next_state = fill_high;
					
                    end
        
        
		activate:   begin
					
					ACTIVE    = 'b1;
					TIMER_EN  = 'b1;
					WASHER_EN = 'b1;
					
					if(WATER_SENSOR_H)
						TIMER_SEL = 'b10;
					else if (WATER_SENSOR_M)
						TIMER_SEL = 'b01;
					
					
					if(TIMER_DONE)
						next_state = drain;
					else
						next_state = activate;
		
		
                    end
        
		drain:      begin
		
					DRAIN    = 'b1;		//Flag
					DRAIN_EN = 'b1;		//Control Enable block
					
					if(!WATER_SENSOR_H && !WATER_SENSOR_M)
						next_state = spin_op;
					else
						next_state = drain;
		
                    end
        
		spin_op:    begin
					
					SPIN      = 'b1;		//Flag
					SPIN_EN   = 'b1;		//Control Enable block
					TIMER_SEL = 'b11;
					
					if(TIMER_DONE)
						next_state = end_op;
					else
						next_state = spin_op;
					
                    end
        
		end_op:     begin
		
					DONE = 'b1;
					
					if(!DOOR_SENSOR)
						next_state = idle_op;
					else
						next_state = end_op;
		
                   
					end               

		default:	begin
						
						current_state = idle_op;
						
						//Flags
						FILLING	= 'b0;
						ACTIVE	= 'b0; 
						DRAIN	= 'b0;
						SPIN	= 'b0; 
						IDLE	= 'b0;  
						DONE	= 'b0; 
						
						//Control Signals
						TIMER_EN   = 'b0;
						WASHER_EN  = 'b0;
						WATER_EN   = 'b0;
						SPIN_EN    = 'b0;
						DRAIN_EN   = 'b0;
						
					end
			
    endcase
 end


endmodule