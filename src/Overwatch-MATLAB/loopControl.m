function Ret = loopControl()
    % Calls the Loop method of the Wrapper class
	x = evalin('base', 'wrapper');
	Ret = x.LoopControl();
end