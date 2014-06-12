function Ret = loopLocalize()
    % Calls the Loop method of the Wrapper class
	x = evalin('base', 'wrapper');
	Ret = x.LoopLocalize();
end