function Ret = loop_sim()
% Calls the Loop method of the Wrapper class
	x = evalin('base', 'simulator');
	Ret = x.Loop();
end