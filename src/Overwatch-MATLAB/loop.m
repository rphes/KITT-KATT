function Ret = loop()
% Calls the Loop method of the Wrapper class
	x = evalin('base', 'wrapper');
	Ret = x.Loop();
end